//
//  LiquidToggle.swift
//  SeaBearKit
//
//  Metaball toggle graduated from the SwiftUI Lab incubator: the knob is a
//  drop of mercury that stretches, pinches in two under speed, ejects
//  satellite droplets, and re-merges at rest.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// A binary toggle whose knob behaves like a drop of mercury: as it moves it
/// stretches into a thin neck, can pinch clean in two under speed, and reforms
/// when it slows. The knob can be tapped or dragged; a drag scrubs the drop
/// under the finger and a release commits by position and flick velocity.
///
/// The liquid look is a metaball field. Two circles are drawn into a `Canvas`
/// layer that is blurred and then alpha-thresholded, so overlapping blobs fuse
/// into one gooey shape and a parting pair thins into a neck. The head circle is
/// the driven position; the tail is the same trajectory delayed by a fixed lag,
/// so the stretch between them is proportional to how fast the drop is moving.
/// Slow drags stay fused, quick flicks neck and pinch off, and the tail always
/// catches up and re-merges at rest. Reduce Motion drops the lag to zero.
///
/// The physics is felt as well as seen: a sharp tick lands at the exact moment
/// the drop pinches in two and a soft one when it re-merges (the settle curves
/// are deterministic, so the ticks are scheduled onto the visual events), and
/// a resting finger squishes the drop slightly before it launches.
///
/// Motion is driven by `TimelineView(.animation)`, not `withAnimation`: a `Canvas`
/// reads its inputs as data, so an animated `@State` would jump rather than
/// interpolate. The timeline redraws the field only while dragging or settling.
///
/// ```swift
/// LiquidToggle(isOn: $isOn, tint: .green)
/// ```
public struct LiquidToggle: View {
    @Binding private var isOn: Bool
    private let tint: Color

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var settled: CGFloat
    @State private var transition: Transition?
    @State private var settleTask: Task<Void, Never>?
    @State private var dragProgress: CGFloat?
    @State private var trace = TailTrace()
    @State private var pinched = false
    @State private var pinchTask: Task<Void, Never>?
    @State private var pressedAt: Date?
    @State private var releaseSquish: ReleaseSquish?
    @State private var droplets: [SplashDroplet] = []
    @State private var dropletCleanup: Task<Void, Never>?

    private struct ReleaseSquish {
        let at: Date
        let from: CGFloat
    }

    private struct Transition {
        let start: Date
        let fromHead: CGFloat
        let fromTail: CGFloat
        let to: CGFloat
        let duration: Double
    }

    public init(isOn: Binding<Bool>, tint: Color = .accentColor) {
        self._isOn = isOn
        self.tint = tint
        self._settled = State(initialValue: isOn.wrappedValue ? 1 : 0)
    }

    private let width: CGFloat = 64
    private let height: CGFloat = 36
    private let inset: CGFloat = 4
    private let baseDuration: Double = 0.45
    // Separation at which the field visibly pinches in two, pinned by an offline
    // scanline sweep of the real thinning + blur + threshold math (27 of the
    // track's 28pt travel: only a full-stretch flick splits the drop).
    // Resizing note: the pinch is radius-invariant at ~1.93x knob radius, so a
    // resized control must re-derive this via the sweep (rasterize the two
    // thinned circles, Gaussian blur 0.42r, 0.5 alpha threshold, bisect the
    // separation where the bridge dies) - and should keep travel/radius at 2.0
    // if it wants to preserve the only-full-stretch-splits feel.
    private let pinchSeparation: CGFloat = 27
    // Extra canvas around the track so ejected droplets can fly above it; the
    // control's layout and hit area stay the plain capsule.
    private let splashMargin: CGFloat = 22

    private var trackCenterY: CGFloat { splashMargin + height / 2 }

    private var knobRadius: CGFloat { (height - inset * 2) / 2 }
    private var offX: CGFloat { inset + knobRadius }
    private var onX: CGFloat { width - inset - knobRadius }
    private var lag: Double { reduceMotion ? 0 : 0.22 }

    private func x(_ progress: CGFloat) -> CGFloat {
        offX + (onX - offX) * progress
    }

    private func progressFor(x locationX: CGFloat) -> CGFloat {
        min(1, max(0, (locationX - offX) / (onX - offX)))
    }

    public var body: some View {
        ZStack {
            Capsule().fill(.gray.opacity(0.25))

            if dragProgress != nil || transition != nil || !droplets.isEmpty {
                TimelineView(.animation) { timeline in
                    knob(
                        head: head(at: timeline.date),
                        tail: tail(at: timeline.date),
                        squish: squish(at: timeline.date),
                        drops: dropletShapes(at: timeline.date)
                    )
                }
            } else {
                knob(head: settled, tail: settled, squish: 0, drops: [])
            }
        }
        .frame(width: width, height: height)
        .contentShape(Capsule())
        .gesture(dragToggle)
        .onChange(of: isOn) { _, now in animate(to: now ? 1 : 0) }
        .accessibilityElement()
        .accessibilityAddTraits(isOn ? [.isButton, .isSelected] : .isButton)
        .accessibilityValue(isOn ? "On" : "Off")
        .accessibilityAction { isOn.toggle() }
    }

    private func head(at date: Date) -> CGFloat {
        if let dragProgress { return dragProgress }
        guard let transition else { return settled }
        let fraction = date.timeIntervalSince(transition.start) / transition.duration
        return transition.fromHead + (transition.to - transition.fromHead) * ease(fraction)
    }

    private func tail(at date: Date) -> CGFloat {
        let now = date.timeIntervalSinceReferenceDate
        if dragProgress != nil { return trace.value(at: now - lag) ?? head(at: date) }
        guard let transition else { return settled }
        let fraction = (date.timeIntervalSince(transition.start) - lag) / transition.duration
        return transition.fromTail + (transition.to - transition.fromTail) * ease(fraction)
    }

    private func knob(head: CGFloat, tail: CGFloat, squish: CGFloat, drops: [(CGPoint, CGFloat)]) -> some View {
        let swell: CGFloat = dragProgress != nil ? 1.07 : 1
        // Volume conservation: the drop thins as it stretches. At 0.22 the field
        // necks hard near tap-transition speeds and pinches clean in two only at
        // full stretch (a fast flick), re-merging as the tail catches up.
        let separation = abs(x(head) - x(tail))
        let thinned = knobRadius * (1 - 0.22 * min(1, separation / (knobRadius * 2)))
        return Canvas { context, _ in
            var field = context
            field.addFilter(.alphaThreshold(min: 0.5, color: tint))
            field.addFilter(.blur(radius: knobRadius * 0.42))
            field.drawLayer { layer in
                blob(in: layer, at: x(tail) + splashMargin, radius: thinned * swell, squish: squish)
                blob(in: layer, at: x(head) + splashMargin, radius: thinned * swell, squish: squish)
            }
            // Droplets get their own lightly blurred pass: under the field's
            // heavy blur a satellite this small would fall below the threshold
            // and vanish. Same tint, so touching shapes still read as one liquid.
            guard !drops.isEmpty else { return }
            var splash = context
            splash.addFilter(.alphaThreshold(min: 0.5, color: tint))
            splash.addFilter(.blur(radius: 2))
            splash.drawLayer { layer in
                for drop in drops {
                    let rect = CGRect(
                        x: drop.0.x - drop.1, y: drop.0.y - drop.1,
                        width: drop.1 * 2, height: drop.1 * 2
                    )
                    layer.fill(Path(ellipseIn: rect), with: .color(.white))
                }
            }
        }
        // The canvas is oversized only so droplets can fly above the track; the
        // outer frame pins the layout size back to the capsule so the control
        // never inflates its container, and the extra canvas just overflows
        // visually (frames do not clip).
        .frame(width: width + splashMargin * 2, height: height + splashMargin * 2)
        .frame(width: width, height: height)
        .allowsHitTesting(false)
    }

    // The drop flattens slightly under a resting finger (area-preserving), the
    // classic anticipation frame before it launches.
    private func blob(in context: GraphicsContext, at centerX: CGFloat, radius: CGFloat, squish: CGFloat) {
        let rx = radius * (1 + 0.1 * squish)
        let ry = radius * (1 - 0.1 * squish)
        let rect = CGRect(x: centerX - rx, y: trackCenterY - ry, width: rx * 2, height: ry * 2)
        context.fill(Path(ellipseIn: rect), with: .color(.white))
    }

    private func dropletShapes(at date: Date) -> [(CGPoint, CGFloat)] {
        let now = date.timeIntervalSinceReferenceDate
        return droplets.compactMap { droplet in
            droplet.shape(at: now).map { ($0.center, $0.radius) }
        }
    }

    private func squish(at date: Date) -> CGFloat {
        if let pressedAt {
            return ease(min(1, date.timeIntervalSince(pressedAt) / 0.1))
        }
        if let releaseSquish {
            return releaseSquish.from * (1 - ease(min(1, date.timeIntervalSince(releaseSquish.at) / 0.15)))
        }
        return 0
    }

    private func ease(_ fraction: Double) -> CGFloat {
        let c = min(1, max(0, fraction))
        return CGFloat(c * c * c * (c * (c * 6 - 15) + 10))
    }

    private var dragToggle: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let now = Date()
                if dragProgress == nil {
                    // Seed the tail with the knob's current position so grabbing
                    // the far end of the track stretches the drop from where it
                    // rests instead of teleporting it whole.
                    var fresh = TailTrace()
                    fresh.append(time: now.timeIntervalSinceReferenceDate - lag, value: tail(at: now))
                    trace = fresh
                    settleTask?.cancel()
                    pinchTask?.cancel()
                    transition = nil
                    pressedAt = now
                    releaseSquish = nil
                }
                let progress = progressFor(x: value.location.x)
                trace.append(time: now.timeIntervalSinceReferenceDate, value: progress)
                dragProgress = progress
                let separation = abs(x(progress) - x(tail(at: now)))
                setPinched(separation > pinchSeparation)
            }
            .onEnded { value in
                let now = Date()
                releaseSquish = ReleaseSquish(at: now, from: squish(at: now))
                pressedAt = nil
                let releaseHead = progressFor(x: value.location.x)
                let releaseTail = tail(at: now)
                let isTap = abs(value.translation.width) < 8 && abs(value.translation.height) < 8
                let target: CGFloat
                if isTap {
                    target = isOn ? 0 : 1
                } else {
                    target = progressFor(x: value.predictedEndLocation.x) > 0.5 ? 1 : 0
                }
                dragProgress = nil
                startTransition(fromHead: releaseHead, fromTail: releaseTail, to: target)
                let nowOn = target == 1
                if nowOn != isOn {
                    isOn = nowOn
                    impact()
                }
            }
    }

    private func animate(to target: CGFloat) {
        // The drag handler starts its own seeded transition before flipping the
        // binding; skip the onChange echo so it is not restarted from scratch.
        if let transition, transition.to == target,
           Date().timeIntervalSince(transition.start) < 0.08 { return }
        let now = Date()
        startTransition(fromHead: head(at: now), fromTail: tail(at: now), to: target)
        impact()
    }

    private func startTransition(fromHead: CGFloat, fromTail: CGFloat, to target: CGFloat) {
        let duration = max(0.2, baseDuration * Double(abs(target - fromHead)))
        transition = Transition(
            start: Date(), fromHead: fromHead, fromTail: fromTail, to: target, duration: duration
        )
        settleTask?.cancel()
        settleTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(duration + lag))
            guard !Task.isCancelled else { return }
            settled = target
            transition = nil
        }
        schedulePinchHaptics(fromHead: fromHead, fromTail: fromTail, to: target, duration: duration)
    }

    // The settle curves are known up front, so the pinch and re-merge ticks are
    // scheduled to fire at the exact moments the field splits and re-fuses.
    private func schedulePinchHaptics(fromHead: CGFloat, fromTail: CGFloat, to target: CGFloat, duration: Double) {
        pinchTask?.cancel()
        let events = LiquidPinch.events(
            fromHead: fromHead, fromTail: fromTail, to: target, duration: duration,
            field: LiquidPinch.Field(travel: onX - offX, threshold: pinchSeparation, lag: lag)
        )
        guard !events.isEmpty else { return }
        pinchTask = Task { @MainActor in
            var elapsed: Double = 0
            for event in events {
                try? await Task.sleep(for: .seconds(event.time - elapsed))
                guard !Task.isCancelled else { return }
                elapsed = event.time
                setPinched(event.pinched)
            }
        }
    }

    private func setPinched(_ value: Bool) {
        guard value != pinched else { return }
        pinched = value
        if value { spawnSplash() }
        #if canImport(UIKit)
        if value {
            HapticHelper.impact(.rigid)
        } else {
            HapticHelper.impact(.soft)
        }
        #endif
    }

    // A snapping liquid neck ejects satellite drops (real fluid dynamics), so
    // the splash spawns at the neck the instant the field pinches. They arc up
    // and away, then blend home so the field swallows them again.
    private func spawnSplash() {
        guard !reduceMotion else { return }
        let now = Date()
        let headX = x(head(at: now)) + splashMargin
        let tailX = x(tail(at: now)) + splashMargin
        let neck = CGPoint(x: (headX + tailX) / 2, y: trackCenterY - 3)
        let direction: CGFloat = headX >= tailX ? 1 : -1
        let homeX = x(transition?.to ?? dragProgress ?? settled) + splashMargin
        let home = CGPoint(x: homeX, y: trackCenterY)
        let born = now.timeIntervalSinceReferenceDate
        var generator = SystemRandomNumberGenerator()
        droplets.append(contentsOf: SplashDroplet.burst(
            at: neck, direction: direction, home: home, born: born, using: &generator
        ))
        dropletCleanup?.cancel()
        dropletCleanup = Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.75))
            guard !Task.isCancelled else { return }
            let cutoff = Date().timeIntervalSinceReferenceDate
            droplets.removeAll { cutoff >= $0.born + $0.lifetime }
        }
    }

    private func impact() {
        #if canImport(UIKit)
        HapticHelper.impact(.light)
        #endif
    }
}

/// When the drop pinches in two and re-merges. Separation over a scripted
/// transition is deterministic (head curve minus the lag-delayed tail curve),
/// so threshold crossings can be computed up front and haptics scheduled to
/// land exactly on the visual events. Pure math, unit tested.
enum LiquidPinch {
    struct Event: Equatable {
        let time: Double
        let pinched: Bool
    }

    /// The field the drop moves through: track travel, the separation at which
    /// it visibly pinches, and the tail's lag.
    struct Field {
        let travel: CGFloat
        let threshold: CGFloat
        let lag: Double
    }

    static func events(
        fromHead: CGFloat, fromTail: CGFloat, to: CGFloat,
        duration: Double, field: Field
    ) -> [Event] {
        let travel = field.travel
        let threshold = field.threshold
        let lag = field.lag
        guard travel > 0, duration > 0, threshold > 0 else { return [] }
        func ease(_ fraction: Double) -> CGFloat {
            let c = min(1, max(0, fraction))
            return CGFloat(c * c * c * (c * (c * 6 - 15) + 10))
        }
        func separation(at t: Double) -> CGFloat {
            let head = fromHead + (to - fromHead) * ease(t / duration)
            let tail = fromTail + (to - fromTail) * ease((t - lag) / duration)
            return abs(head - tail) * travel
        }
        let span = duration + lag
        let steps = max(2, Int(span * 240))
        var events: [Event] = []
        var wasPinched = separation(at: 0) > threshold
        for step in 1...steps {
            let time = Double(step) / Double(steps) * span
            let pinched = separation(at: time) > threshold
            if pinched != wasPinched {
                events.append(Event(time: time, pinched: pinched))
                wasPinched = pinched
            }
        }
        return events
    }
}

/// A satellite drop ejected when the field pinches: ballistic flight for the
/// first half of its life, then blended back toward `home` so the field
/// re-absorbs it. Pure math, unit tested.
struct SplashDroplet: Equatable {
    let born: Double
    let start: CGPoint
    let velocity: CGVector
    let radius: CGFloat
    let lifetime: Double
    let home: CGPoint

    static let gravity: Double = 380

    func shape(at time: Double) -> (center: CGPoint, radius: CGFloat)? {
        let t = time - born
        guard t >= 0, t < lifetime else { return nil }
        let phase = t / lifetime
        let ballisticX = Double(start.x) + Double(velocity.dx) * t
        let ballisticY = Double(start.y) + Double(velocity.dy) * t + 0.5 * Self.gravity * t * t
        let pull = Self.smoothstep((phase - 0.5) / 0.5)
        let x = ballisticX + (Double(home.x) - ballisticX) * pull
        let y = ballisticY + (Double(home.y) - ballisticY) * pull
        return (CGPoint(x: x, y: y), radius * CGFloat(1 - 0.25 * phase))
    }

    private static func smoothstep(_ x: Double) -> Double {
        let c = min(1, max(0, x))
        return c * c * (3 - 2 * c)
    }

    /// A randomized burst of satellite drops off a snapping neck. Count, size,
    /// launch velocity, lifetime, and spawn stagger all jitter within ranges
    /// tuned so every splash reads lively but none produces duds or outliers;
    /// no two splashes match. The generator is injected so tests can seed it.
    static func burst(
        at neck: CGPoint, direction: CGFloat, home: CGPoint, born: Double,
        using generator: inout some RandomNumberGenerator
    ) -> [SplashDroplet] {
        let count = Int.random(in: 2...4, using: &generator)
        return (0..<count).map { _ in
            SplashDroplet(
                born: born + Double.random(in: 0...0.05, using: &generator),
                start: CGPoint(x: neck.x + CGFloat.random(in: -2...2, using: &generator), y: neck.y),
                velocity: CGVector(
                    dx: -direction * CGFloat.random(in: 18...70, using: &generator),
                    dy: -CGFloat.random(in: 55...135, using: &generator)
                ),
                radius: CGFloat.random(in: 1.8...3.6, using: &generator),
                lifetime: Double.random(in: 0.42...0.66, using: &generator),
                home: home
            )
        }
    }
}

/// A short history of the head's positions, sampled while dragging, so the tail
/// can read the same trajectory a fixed lag in the past. Pure math, unit tested.
struct TailTrace {
    private(set) var samples: [(time: Double, value: CGFloat)] = []

    mutating func append(time: Double, value: CGFloat) {
        samples.append((time, value))
        let cutoff = time - 1.5
        if let firstKept = samples.firstIndex(where: { $0.time >= cutoff }), firstKept > 1 {
            samples.removeFirst(firstKept - 1)
        }
    }

    func value(at time: Double) -> CGFloat? {
        guard let first = samples.first, let last = samples.last else { return nil }
        if time <= first.time { return first.value }
        if time >= last.time { return last.value }
        for index in 1..<samples.count where samples[index].time >= time {
            let from = samples[index - 1]
            let to = samples[index]
            let span = to.time - from.time
            guard span > 0 else { return to.value }
            let fraction = (time - from.time) / span
            return from.value + (to.value - from.value) * CGFloat(fraction)
        }
        return last.value
    }
}

#Preview {
    struct Demo: View {
        @State private var wifi = false
        @State private var focus = true
        var body: some View {
            VStack(spacing: 28) {
                LiquidToggle(isOn: $wifi)
                LiquidToggle(isOn: $focus, tint: .green)
                LiquidToggle(isOn: .constant(true), tint: .purple)
            }
            .padding(40)
        }
    }
    return Demo()
}

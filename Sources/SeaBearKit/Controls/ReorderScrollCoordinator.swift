//
//  ReorderScrollCoordinator.swift
//  SeaBearKit
//
//  UIKit half of ReorderableVStack: a long-press recognizer on the
//  enclosing scroll view for hold-vs-pan coexistence, plus edge auto-scroll.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Pure auto-scroll math, unit tested in the package: scroll velocity (points
/// per second, positive scrolls down) for a dragged row near the visible
/// edges. Zero outside the edge zones, ramping linearly to `maxSpeed` as the
/// row pushes into them.
enum AutoScrollMath {
    static func velocity(
        rowTop: CGFloat, rowBottom: CGFloat,
        visible: ClosedRange<CGFloat>,
        edgeZone: CGFloat, maxSpeed: CGFloat
    ) -> CGFloat {
        guard edgeZone > 0 else { return 0 }
        let topIntrusion = (visible.lowerBound + edgeZone) - rowTop
        if topIntrusion > 0 {
            return -maxSpeed * min(1, topIntrusion / edgeZone)
        }
        let bottomIntrusion = rowBottom - (visible.upperBound - edgeZone)
        if bottomIntrusion > 0 {
            return maxSpeed * min(1, bottomIntrusion / edgeZone)
        }
        return 0
    }
}

#if canImport(UIKit)
/// The UIKit half of the reorder gesture. SwiftUI drag gestures, even
/// simultaneous zero-distance ones, do not co-recognize with UIScrollView's
/// pan, so any SwiftUI-side press handling blocks scrolling once rows cover
/// the screen. Instead a UILongPressGestureRecognizer is installed on the
/// enclosing scroll view itself, the system's native hold-vs-pan coexistence:
/// swipes pan, movement cancels the hold, and a stationary hold lifts the row,
/// freezing the scroll view until release. A delegate filter restricts the
/// recognizer to touches inside the stack. The same object owns clamped
/// auto-scroll stepping; the anchor view (the stack's background) bridges row
/// positions and scroll content coordinates.
@MainActor
final class ReorderScrollCoordinator: NSObject, UIGestureRecognizerDelegate {
    weak var scrollView: UIScrollView? {
        didSet { if scrollView !== oldValue { installRecognizer() } }
    }
    weak var anchor: UIView?

    var activationDelay: TimeInterval = 0.3 {
        didSet { recognizer?.minimumPressDuration = activationDelay }
    }
    var slotHeight: CGFloat = 64
    var rowCount: Int = 0
    var onLift: ((Int) -> Void)?
    var onMove: ((CGFloat, CGFloat) -> Void)?
    var onEnd: (() -> Void)?

    private var recognizer: UILongPressGestureRecognizer?
    private var startY: CGFloat = 0
    private var lastY: CGFloat = 0
    private var lastTime: Date = .distantPast
    private var smoothedVelocity: CGFloat = 0

    private let edgeZone: CGFloat = 56
    private let maxSpeed: CGFloat = 420

    private func installRecognizer() {
        if let recognizer, let host = recognizer.view {
            host.removeGestureRecognizer(recognizer)
        }
        recognizer = nil
        guard let scrollView else { return }
        let press = UILongPressGestureRecognizer(target: self, action: #selector(handlePress))
        press.minimumPressDuration = activationDelay
        press.delegate = self
        scrollView.addGestureRecognizer(press)
        recognizer = press
    }

    func detach() {
        if let recognizer, let host = recognizer.view {
            host.removeGestureRecognizer(recognizer)
        }
        recognizer = nil
        scrollView?.isScrollEnabled = true
    }

    @objc private func handlePress(_ press: UILongPressGestureRecognizer) {
        guard let anchor else { return }
        let location = press.location(in: anchor)
        switch press.state {
        case .began:
            guard slotHeight > 0 else { return }
            let index = Int(location.y / slotHeight)
            guard (0..<rowCount).contains(index) else { return }
            startY = location.y
            lastY = location.y
            lastTime = Date()
            smoothedVelocity = 0
            scrollView?.isScrollEnabled = false
            onLift?(index)
        case .changed:
            let now = Date()
            // Raw per-event velocity is jittery (tiny dt, quantized touches);
            // low-pass it so the row's lean reads as motion, not noise.
            let dt = max(0.008, now.timeIntervalSince(lastTime))
            let raw = (location.y - lastY) / dt
            smoothedVelocity += (raw - smoothedVelocity) * 0.25
            lastY = location.y
            lastTime = now
            onMove?(location.y - startY, smoothedVelocity)
        case .ended, .cancelled, .failed:
            scrollView?.isScrollEnabled = true
            onEnd?()
        default:
            break
        }
    }

    // Auto-scroll: nudge the offset, then refresh the translation from the live
    // touch location. The anchor moves with the content, so the conversion
    // already accounts for the scroll, keeping the row pinned under a
    // stationary finger with no separate compensation.
    func autoScrollTick(rowTop: CGFloat, rowHeight: CGFloat, dt: Double) {
        guard let scrollView, let anchor else { return }
        let originY = anchor.convert(CGPoint.zero, to: scrollView).y
        let rowTopContent = originY + rowTop
        let insetTop = scrollView.adjustedContentInset.top
        let insetBottom = scrollView.adjustedContentInset.bottom
        let visibleTop = scrollView.contentOffset.y + insetTop
        let visibleBottom = scrollView.contentOffset.y + scrollView.bounds.height - insetBottom
        guard visibleTop < visibleBottom else { return }
        let velocity = AutoScrollMath.velocity(
            rowTop: rowTopContent,
            rowBottom: rowTopContent + rowHeight,
            visible: visibleTop...visibleBottom,
            edgeZone: edgeZone,
            maxSpeed: maxSpeed
        )
        guard velocity != 0 else { return }
        let minOffset = -insetTop
        let maxOffset = max(
            minOffset,
            scrollView.contentSize.height + insetBottom - scrollView.bounds.height
        )
        let current = scrollView.contentOffset.y
        let target = min(maxOffset, max(minOffset, current + velocity * CGFloat(dt)))
        guard abs(target - current) > 0.01 else { return }
        scrollView.contentOffset.y = target
        if let press = recognizer, press.state == .began || press.state == .changed {
            let location = press.location(in: anchor)
            lastY = location.y
            onMove?(location.y - startY, 0)
        }
    }

    // Only touches inside the stack ever reach the recognizer, so holds on
    // other scroll content behave as if it were never installed.
    nonisolated func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch
    ) -> Bool {
        MainActor.assumeIsolated {
            guard let anchor else { return false }
            return anchor.bounds.contains(touch.location(in: anchor))
        }
    }

    nonisolated func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}

/// Invisible background view that resolves the enclosing UIScrollView by
/// walking the superview chain once mounted, and pushes the control's current
/// configuration into the coordinator on every SwiftUI update.
struct ScrollViewGrabber: UIViewRepresentable {
    let coordinator: ReorderScrollCoordinator
    let configure: (ReorderScrollCoordinator) -> Void

    func makeUIView(context: Context) -> GrabberView {
        GrabberView(coordinator: coordinator)
    }

    func updateUIView(_ uiView: GrabberView, context: Context) {
        configure(coordinator)
    }

    final class GrabberView: UIView {
        private let coordinator: ReorderScrollCoordinator

        init(coordinator: ReorderScrollCoordinator) {
            self.coordinator = coordinator
            super.init(frame: .zero)
            isUserInteractionEnabled = false
            backgroundColor = .clear
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) { nil }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            guard window != nil else {
                coordinator.detach()
                return
            }
            coordinator.anchor = self
            var candidate = superview
            while let current = candidate, !(current is UIScrollView) {
                candidate = current.superview
            }
            coordinator.scrollView = candidate as? UIScrollView
        }
    }
}
#endif

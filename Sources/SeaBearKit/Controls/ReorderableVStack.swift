//
//  ReorderableVStack.swift
//  SeaBearKit
//
//  Press-and-hold drag-to-reorder stack with gap-open rows,
//  scroll coexistence, edge auto-scroll, and haptic choreography.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// A vertical stack whose rows can be reordered by press-and-hold then drag,
/// with full control over the row's appearance (unlike `List` + `.onMove`,
/// whose system drag-lift draws an un-removable background box).
///
/// Smoothness comes from NOT mutating `items` during the drag: the array stays
/// put while a gap opens (neighbouring rows offset out of the way) and the
/// dragged row follows the finger. The reorder is committed once, on release.
///
/// Scroll coexistence works by watching, not blocking: a simultaneous
/// zero-distance drag observes every row without claiming the scroll pan, so a
/// swipe from any row scrolls the host even when rows fill the screen. A
/// finger that stays put for `activationDelay` lifts the row instead (shadow
/// and scale before any movement), freezes the enclosing scroll view so all
/// further motion belongs to the reorder, and releases it on drop.
///
/// ```swift
/// ReorderableVStack(items: $items) { item in
///     Text(item.title)
/// }
/// ```
public struct ReorderableVStack<Item: Identifiable, Row: View>: View {
    @Binding private var items: [Item]
    private let rowHeight: CGFloat
    private let spacing: CGFloat
    private let activationDelay: TimeInterval
    private let row: (Item) -> Row

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var draggingIndex: Int?
    @State private var settlingIndex: Int?
    @State private var settleGen = 0
    @State private var translation: CGFloat = 0
    @State private var lastTarget: Int?
    @State private var tilt: Double = 0
    @State private var tiltSettle: Task<Void, Never>?
    @State private var autoScrollTask: Task<Void, Never>?
    @State private var holdTask: Task<Void, Never>?
    @State private var pendingIndex: Int?
    @State private var holdTranslation: CGFloat = 0
    @State private var liftBase: CGFloat = 0
    #if canImport(UIKit)
    @State private var scrollCoordinator = ReorderScrollCoordinator()
    #endif

    public init(
        items: Binding<[Item]>,
        rowHeight: CGFloat = 56,
        spacing: CGFloat = 8,
        activationDelay: TimeInterval = 0.3,
        @ViewBuilder row: @escaping (Item) -> Row
    ) {
        self._items = items
        self.rowHeight = rowHeight
        self.spacing = spacing
        self.activationDelay = activationDelay
        self.row = row
    }

    private var slotHeight: CGFloat { rowHeight + spacing }

    private var targetIndex: Int? {
        guard let from = draggingIndex else { return nil }
        return ReorderMath.targetIndex(
            from: from, dragOffset: translation, slotHeight: slotHeight, count: items.count
        )
    }

    public var body: some View {
        VStack(spacing: spacing) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                let isDragging = draggingIndex == index
                row(item)
                    .frame(maxWidth: .infinity)
                    .frame(height: rowHeight)
                    .contentShape(Rectangle())
                    .scaleEffect(isDragging && !reduceMotion ? 1.03 : 1)
                    .rotationEffect(.degrees(isDragging ? tilt : 0))
                    // Flatten before shadowing: without the compositing group the
                    // shadow applies to every subview individually, haloing the
                    // row's inner content and shimmering as the row moves.
                    .compositingGroup()
                    .shadow(color: .black.opacity(isDragging ? 0.18 : 0), radius: isDragging ? 8 : 0, y: 4)
                    .offset(y: yOffset(for: index))
                    // zIndex is not animatable, so the elevation must outlive
                    // the drag: a released row keeps floating until its settle
                    // spring completes, or it slides under a neighbour mid-flight.
                    .zIndex(isDragging || settlingIndex == index ? 1 : 0)
                    // Only the gap opening animates; the dragged row tracks the finger
                    // 1:1, so it opts out of the targetIndex animation entirely (a
                    // shared transaction would otherwise lag its offset at each slot
                    // crossing). Rows farther from the drag respond slightly later,
                    // so the gap opens as a wave.
                    .animation(
                        isDragging
                            ? nil
                            : .spring(response: 0.28, dampingFraction: 0.72)
                                .delay(Double(abs(index - (draggingIndex ?? index))) * 0.018),
                        value: targetIndex
                    )
                    #if !canImport(UIKit)
                    .simultaneousGesture(reorderGesture(for: index))
                    #endif
                    .accessibilityAction(named: "Move Up") { move(index, by: -1) }
                    .accessibilityAction(named: "Move Down") { move(index, by: 1) }
            }
        }
        .onDisappear {
            cancelHold()
            restoreScroll()
        }
        #if canImport(UIKit)
        .background(ScrollViewGrabber(coordinator: scrollCoordinator) { coordinator in
            coordinator.activationDelay = activationDelay
            coordinator.slotHeight = slotHeight
            coordinator.rowCount = items.count
            coordinator.onLift = { index in lift(index) }
            coordinator.onMove = { translationY, velocity in
                followFinger(translationY: translationY, velocity: velocity)
            }
            coordinator.onEnd = { commit() }
        })
        #endif
    }

    private func lift(_ index: Int) {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
            draggingIndex = index
        }
        lastTarget = index
        translation = 0
        startAutoScroll()
        #if canImport(UIKit)
        HapticHelper.impact(.medium)
        #endif
    }

    private func followFinger(translationY: CGFloat, velocity: CGFloat) {
        guard draggingIndex != nil else { return }
        translation = translationY
        if let target = targetIndex, target != lastTarget {
            lastTarget = target
            #if canImport(UIKit)
            HapticHelper.selection()
            #endif
        }
        if velocity != 0 { updateTilt(velocity: velocity) }
    }

    private func move(_ index: Int, by offset: Int) {
        let target = index + offset
        guard items.indices.contains(index), items.indices.contains(target) else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) {
            items.swapAt(index, target)
        }
    }

    // While a drag holds a row inside an edge zone of the enclosing scroll
    // view, nudge the scroll offset every frame and add the same delta to the
    // drag translation, so the row stays pinned under the stationary finger
    // while the list slides beneath it.
    private func startAutoScroll() {
        #if canImport(UIKit)
        autoScrollTask?.cancel()
        autoScrollTask = Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1.0 / 60))
                guard !Task.isCancelled, let from = draggingIndex else { return }
                scrollCoordinator.autoScrollTick(
                    rowTop: CGFloat(from) * slotHeight + translation,
                    rowHeight: rowHeight,
                    dt: 1.0 / 60
                )
            }
        }
        #endif
    }

    private func stopAutoScroll() {
        autoScrollTask?.cancel()
        autoScrollTask = nil
    }

    private func yOffset(for index: Int) -> CGFloat {
        if draggingIndex == index {
            return elasticTranslation(from: index)
        }
        guard let from = draggingIndex, let to = targetIndex else { return 0 }
        return CGFloat(ReorderMath.displacement(index: index, draggingIndex: from, targetIndex: to)) * slotHeight
    }

    // Past the first or last slot the row rubber-bands instead of running free,
    // damped through SeaBearKit's ElasticDrag helper.
    private func elasticTranslation(from index: Int) -> CGFloat {
        let lower = -CGFloat(index) * slotHeight
        let upper = CGFloat(items.count - 1 - index) * slotHeight
        let clamped = min(upper, max(lower, translation))
        let overshoot = translation - clamped
        return clamped + ElasticDrag.value(overshoot, comfortZone: 0)
    }

    // Non-UIKit fallback (macOS demo builds): a simultaneous zero-distance drag
    // with manual hold detection. On iOS the UILongPressGestureRecognizer in
    // ReorderScrollCoordinator drives the interaction instead, because SwiftUI
    // drag gestures do not co-recognize with UIScrollView's pan.
    private func reorderGesture(for index: Int) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in dragChanged(index: index, value: value) }
            .onEnded { _ in dragEnded(index: index) }
    }

    private func dragChanged(index: Int, value: DragGesture.Value) {
        if draggingIndex == index {
            translation = value.translation.height - liftBase
            if let target = targetIndex, target != lastTarget {
                lastTarget = target
                #if canImport(UIKit)
                HapticHelper.selection()
                #endif
            }
            updateTilt(velocity: value.velocity.height)
            return
        }
        guard draggingIndex == nil else { return }
        if pendingIndex != index {
            beginHold(index: index)
        }
        holdTranslation = value.translation.height
        if hypot(value.translation.width, value.translation.height) > 10 {
            cancelHold()
        }
    }

    private func dragEnded(index: Int) {
        if draggingIndex == index {
            commit()
        } else if pendingIndex == index {
            cancelHold()
        }
    }

    private func beginHold(index: Int) {
        holdTask?.cancel()
        pendingIndex = index
        holdTranslation = 0
        holdTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(activationDelay))
            guard !Task.isCancelled, pendingIndex == index, draggingIndex == nil else { return }
            #if canImport(UIKit)
            if scrollCoordinator.scrollView?.isDragging == true {
                pendingIndex = nil
                return
            }
            scrollCoordinator.scrollView?.isScrollEnabled = false
            #endif
            liftBase = holdTranslation
            draggingIndex = index
            lastTarget = index
            startAutoScroll()
            #if canImport(UIKit)
            HapticHelper.impact(.medium)
            #endif
        }
    }

    private func cancelHold() {
        holdTask?.cancel()
        holdTask = nil
        pendingIndex = nil
    }

    private func restoreScroll() {
        #if canImport(UIKit)
        scrollCoordinator.scrollView?.isScrollEnabled = true
        #endif
    }

    // The dragged row leans with its vertical speed and rights itself when the
    // finger slows; drag events stop when the finger holds still, so a short
    // settle task relaxes the lean instead of freezing it mid-tilt. Skipped
    // entirely under Reduce Motion (the lean is decorative, not feedback).
    private func updateTilt(velocity: CGFloat) {
        guard !reduceMotion else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            tilt = max(-2.5, min(2.5, Double(velocity) / 600))
        }
        tiltSettle?.cancel()
        tiltSettle = Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.1))
            guard !Task.isCancelled else { return }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { tilt = 0 }
        }
    }

    private func commit() {
        stopAutoScroll()
        cancelHold()
        restoreScroll()
        tiltSettle?.cancel()
        tilt = 0
        liftBase = 0
        guard let from = draggingIndex, let to = targetIndex else {
            draggingIndex = nil
            translation = 0
            lastTarget = nil
            return
        }
        #if canImport(UIKit)
        HapticHelper.impact(.soft)
        #endif
        settlingIndex = to
        settleGen += 1
        let gen = settleGen
        withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) {
            if to != from {
                let moved = items.remove(at: from)
                items.insert(moved, at: to)
            }
            draggingIndex = nil
            translation = 0
        } completion: {
            guard settleGen == gen else { return }
            settlingIndex = nil
        }
        lastTarget = nil
    }
}

/// Pure reorder math, unit tested in the package.
enum ReorderMath {
    /// Index a row dragged `dragOffset` from its original index `from` lands on,
    /// given a fixed per-row `slotHeight`. Clamped to `0..<count`.
    static func targetIndex(from: Int, dragOffset: CGFloat, slotHeight: CGFloat, count: Int) -> Int {
        guard slotHeight > 0, count > 0 else { return from }
        let step = Int((dragOffset / slotHeight).rounded())
        return min(count - 1, max(0, from + step))
    }

    /// How many slots (-1, 0, +1) a non-dragged row at `index` shifts to open the
    /// gap for a drag from `draggingIndex` heading to `targetIndex`.
    static func displacement(index: Int, draggingIndex: Int, targetIndex: Int) -> Int {
        guard index != draggingIndex else { return 0 }
        if draggingIndex < targetIndex {
            return (index > draggingIndex && index <= targetIndex) ? -1 : 0
        }
        if targetIndex < draggingIndex {
            return (index >= targetIndex && index < draggingIndex) ? 1 : 0
        }
        return 0
    }
}

#Preview {
    struct Demo: View {
        struct Item: Identifiable { let id = UUID(); let label: String }
        @State var items = ["Alpha", "Bravo", "Charlie", "Delta"].map { Item(label: $0) }
        var body: some View {
            ReorderableVStack(items: $items) { item in
                Text(item.label)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .background(.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
    }
    return Demo()
}

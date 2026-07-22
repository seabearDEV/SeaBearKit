//
//  ReorderControlTests.swift
//  SeaBearKitTests
//
//  Unit tests for the pure logic behind ReorderableVStack: reorder targeting,
//  gap displacement, edge auto-scroll velocity, and elastic drag damping.
//  Ported from SwiftUILabKit (the incubator) alongside the control.
//

import XCTest
import CoreGraphics
@testable import SeaBearKit

final class ElasticDragTests: XCTestCase {
    let comfortZone: CGFloat = 100

    func testWithinComfortZonePassesThrough() {
        XCTAssertEqual(ElasticDrag.value(50, comfortZone: comfortZone), 50)
        XCTAssertEqual(ElasticDrag.value(0, comfortZone: comfortZone), 0)
        XCTAssertEqual(ElasticDrag.value(100, comfortZone: comfortZone), 100)
        XCTAssertEqual(ElasticDrag.value(-50, comfortZone: comfortZone), -50)
        XCTAssertEqual(ElasticDrag.value(-100, comfortZone: comfortZone), -100)
    }

    func testBeyondComfortZoneAppliesLogDamping() {
        let result = ElasticDrag.value(200, comfortZone: comfortZone)
        XCTAssertGreaterThan(result, comfortZone)
        XCTAssertLessThan(result, 200, "Damped value should trail the raw drag")
        XCTAssertEqual(result, 100 + log(1 + 100) * 8, accuracy: 0.001)
    }

    func testSymmetricBehavior() {
        let positive = ElasticDrag.value(300, comfortZone: comfortZone)
        let negative = ElasticDrag.value(-300, comfortZone: comfortZone)
        XCTAssertEqual(positive, -negative, accuracy: 0.001)
    }

    func testDiminishingReturns() {
        let delta1 = ElasticDrag.value(300, comfortZone: comfortZone) - ElasticDrag.value(200, comfortZone: comfortZone)
        let delta2 = ElasticDrag.value(400, comfortZone: comfortZone) - ElasticDrag.value(300, comfortZone: comfortZone)
        XCTAssertLessThan(delta2, delta1, "Each additional point of drag should move less")
    }

    func testZeroComfortZoneAlwaysDamps() {
        let result = ElasticDrag.value(50, comfortZone: 0)
        XCTAssertLessThan(result, 50)
        XCTAssertGreaterThan(result, 0)
    }
}

final class ReorderMathTests: XCTestCase {
    let slot: CGFloat = 64

    func testTargetIndexTracksTheDrag() {
        XCTAssertEqual(ReorderMath.targetIndex(from: 2, dragOffset: 0, slotHeight: slot, count: 5), 2)
        XCTAssertEqual(ReorderMath.targetIndex(from: 1, dragOffset: 31, slotHeight: slot, count: 5), 1)
        XCTAssertEqual(ReorderMath.targetIndex(from: 0, dragOffset: slot, slotHeight: slot, count: 5), 1)
        XCTAssertEqual(ReorderMath.targetIndex(from: 4, dragOffset: -slot * 2, slotHeight: slot, count: 5), 2)
    }

    func testTargetIndexClampsToTheList() {
        XCTAssertEqual(ReorderMath.targetIndex(from: 4, dragOffset: slot * 10, slotHeight: slot, count: 5), 4)
        XCTAssertEqual(ReorderMath.targetIndex(from: 0, dragOffset: -slot * 10, slotHeight: slot, count: 5), 0)
    }

    func testTargetIndexDegenerateInputsStayPut() {
        XCTAssertEqual(ReorderMath.targetIndex(from: 1, dragOffset: 50, slotHeight: 0, count: 5), 1)
        XCTAssertEqual(ReorderMath.targetIndex(from: 1, dragOffset: 50, slotHeight: slot, count: 0), 1)
    }

    func testRowsBetweenDragAndTargetShiftTowardTheGap() {
        // Dragging row 1 down to slot 3: rows 2 and 3 shift up one slot.
        XCTAssertEqual(ReorderMath.displacement(index: 2, draggingIndex: 1, targetIndex: 3), -1)
        XCTAssertEqual(ReorderMath.displacement(index: 3, draggingIndex: 1, targetIndex: 3), -1)
        XCTAssertEqual(ReorderMath.displacement(index: 4, draggingIndex: 1, targetIndex: 3), 0)
        XCTAssertEqual(ReorderMath.displacement(index: 0, draggingIndex: 1, targetIndex: 3), 0)
        // Dragging row 3 up to slot 1: rows 1 and 2 shift down one slot.
        XCTAssertEqual(ReorderMath.displacement(index: 1, draggingIndex: 3, targetIndex: 1), 1)
        XCTAssertEqual(ReorderMath.displacement(index: 2, draggingIndex: 3, targetIndex: 1), 1)
    }

    func testDraggedRowNeverDisplacesItself() {
        XCTAssertEqual(ReorderMath.displacement(index: 2, draggingIndex: 2, targetIndex: 4), 0)
    }
}

final class AutoScrollMathTests: XCTestCase {
    let visibleTop: CGFloat = 100
    let visibleBottom: CGFloat = 700
    let zone: CGFloat = 56
    let maxSpeed: CGFloat = 420

    private func velocity(rowTop: CGFloat, rowHeight: CGFloat = 56) -> CGFloat {
        AutoScrollMath.velocity(
            rowTop: rowTop, rowBottom: rowTop + rowHeight,
            visible: visibleTop...visibleBottom,
            edgeZone: zone, maxSpeed: maxSpeed
        )
    }

    func testRestsInTheMiddle() {
        XCTAssertEqual(velocity(rowTop: 400), 0)
    }

    func testScrollsUpNearTheTopAndRampsWithIntrusion() {
        let shallow = velocity(rowTop: visibleTop + zone - 10)
        let deep = velocity(rowTop: visibleTop + 5)
        XCTAssertLessThan(shallow, 0)
        XCTAssertLessThan(deep, shallow)
    }

    func testScrollsDownNearTheBottomAndRampsWithIntrusion() {
        let shallow = velocity(rowTop: visibleBottom - zone - 56 + 10)
        let deep = velocity(rowTop: visibleBottom - 56 - 5)
        XCTAssertGreaterThan(shallow, 0)
        XCTAssertGreaterThan(deep, shallow)
    }

    func testSpeedIsClampedAtTheMaximum() {
        XCTAssertEqual(velocity(rowTop: visibleTop - 300), -maxSpeed)
        XCTAssertEqual(velocity(rowTop: visibleBottom + 300), maxSpeed)
    }

    func testDegenerateZoneIsInert() {
        let value = AutoScrollMath.velocity(
            rowTop: 0, rowBottom: 56, visible: 0...600,
            edgeZone: 0, maxSpeed: maxSpeed
        )
        XCTAssertEqual(value, 0)
    }
}

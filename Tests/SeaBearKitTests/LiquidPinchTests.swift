import Testing
import CoreGraphics
@testable import SeaBearKit

struct LiquidPinchTests {
    let field = LiquidPinch.Field(travel: 28, threshold: 27, lag: 0.22)
    let lag = 0.22

    @Test func tapToggleNeverPinches() {
        let events = LiquidPinch.events(
            fromHead: 0, fromTail: 0, to: 1,
            duration: 0.45, field: field
        )
        #expect(events.isEmpty)
    }

    @Test func fullStretchFlickPinchesThenRemerges() {
        let events = LiquidPinch.events(
            fromHead: 0.9, fromTail: 0, to: 1,
            duration: 0.2, field: field
        )
        #expect(events.count == 2)
        #expect(events.first?.pinched == true)
        #expect(events.last?.pinched == false)
        if let pinch = events.first, let merge = events.last {
            #expect(pinch.time < merge.time)
            #expect(merge.time <= 0.2 + lag)
        }
    }

    @Test func alreadyPinchedStartOnlyRemerges() {
        let events = LiquidPinch.events(
            fromHead: 1, fromTail: 0, to: 1,
            duration: 0.2, field: field
        )
        #expect(events.count == 1)
        #expect(events.first?.pinched == false)
    }

    @Test func zeroLagNeverPinches() {
        let events = LiquidPinch.events(
            fromHead: 0.9, fromTail: 0, to: 1,
            duration: 0.2, field: LiquidPinch.Field(travel: 28, threshold: 27, lag: 0)
        )
        #expect(events.isEmpty)
    }

    @Test func degenerateInputsProduceNoEvents() {
        #expect(LiquidPinch.events(
            fromHead: 0, fromTail: 0, to: 1,
            duration: 0, field: field
        ).isEmpty)
        #expect(LiquidPinch.events(
            fromHead: 0, fromTail: 0, to: 1,
            duration: 0.45, field: LiquidPinch.Field(travel: 0, threshold: 27, lag: 0.22)
        ).isEmpty)
    }

    @Test func eventTimesAreStrictlyIncreasing() {
        let events = LiquidPinch.events(
            fromHead: 0.95, fromTail: 0.05, to: 0,
            duration: 0.43, field: field
        )
        for pair in zip(events, events.dropFirst()) {
            #expect(pair.0.time < pair.1.time)
            #expect(pair.0.pinched != pair.1.pinched)
        }
    }
}

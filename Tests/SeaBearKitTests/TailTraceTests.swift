import Testing
import CoreGraphics
@testable import SeaBearKit

struct TailTraceTests {
    @Test func emptyTraceHasNoValue() {
        let trace = TailTrace()
        #expect(trace.value(at: 0) == nil)
    }

    @Test func singleSampleAnswersEverywhere() {
        var trace = TailTrace()
        trace.append(time: 10, value: 0.4)
        #expect(trace.value(at: 5) == 0.4)
        #expect(trace.value(at: 10) == 0.4)
        #expect(trace.value(at: 20) == 0.4)
    }

    @Test func interpolatesBetweenSamples() {
        var trace = TailTrace()
        trace.append(time: 0, value: 0)
        trace.append(time: 1, value: 1)
        #expect(abs((trace.value(at: 0.5) ?? -1) - 0.5) < 0.0001)
        #expect(abs((trace.value(at: 0.25) ?? -1) - 0.25) < 0.0001)
    }

    @Test func clampsBeforeFirstAndAfterLast() {
        var trace = TailTrace()
        trace.append(time: 1, value: 0.2)
        trace.append(time: 2, value: 0.8)
        #expect(trace.value(at: 0) == 0.2)
        #expect(trace.value(at: 3) == 0.8)
    }

    @Test func duplicateTimestampsDoNotDivideByZero() {
        var trace = TailTrace()
        trace.append(time: 1, value: 0.2)
        trace.append(time: 1, value: 0.6)
        let value = trace.value(at: 1)
        #expect(value == 0.2 || value == 0.6)
    }

    @Test func prunesOldSamplesButKeepsOneBeforeCutoff() {
        var trace = TailTrace()
        for tick in 0..<100 {
            trace.append(time: Double(tick) * 0.1, value: CGFloat(tick) / 100)
        }
        let newest = 9.9
        #expect(trace.samples.allSatisfy { $0.time >= newest - 1.5 - 0.2 })
        // A lagged read just inside the window still interpolates.
        #expect(trace.value(at: newest - 1.0) != nil)
    }

    @Test func laggedReadTracksHistoryNotPresent() {
        var trace = TailTrace()
        trace.append(time: 0, value: 0)
        trace.append(time: 0.1, value: 0.5)
        trace.append(time: 0.2, value: 1)
        let lagged = trace.value(at: 0.2 - 0.1)
        #expect(abs((lagged ?? -1) - 0.5) < 0.0001)
    }
}

import Testing
import CoreGraphics
@testable import SeaBearKit

struct SplashDropletTests {
    let droplet = SplashDroplet(
        born: 100,
        start: CGPoint(x: 50, y: 40),
        velocity: CGVector(dx: -40, dy: -80),
        radius: 3,
        lifetime: 0.5,
        home: CGPoint(x: 60, y: 43)
    )

    @Test func absentOutsideItsLifetime() {
        #expect(droplet.shape(at: 99.9) == nil)
        #expect(droplet.shape(at: 100.5) == nil)
        #expect(droplet.shape(at: 101) == nil)
    }

    @Test func launchesFromTheNeck() {
        let shape = droplet.shape(at: 100)
        #expect(shape != nil)
        if let shape {
            #expect(abs(shape.center.x - 50) < 0.001)
            #expect(abs(shape.center.y - 40) < 0.001)
            #expect(shape.radius == 3)
        }
    }

    @Test func fliesBallisticallyEarly() {
        let shape = droplet.shape(at: 100.1)
        #expect(shape != nil)
        if let shape {
            #expect(shape.center.x < 50)
            #expect(shape.center.y < 40)
        }
    }

    @Test func returnsHomeToBeReabsorbed() {
        let shape = droplet.shape(at: 100.499)
        #expect(shape != nil)
        if let shape {
            #expect(abs(shape.center.x - 60) < 1)
            #expect(abs(shape.center.y - 43) < 1)
            #expect(shape.radius < 3)
        }
    }

    private struct SeededGenerator: RandomNumberGenerator {
        var state: UInt64
        mutating func next() -> UInt64 {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return state
        }
    }

    @Test func burstStaysWithinItsTunedRanges() {
        var generator = SeededGenerator(state: 7)
        for _ in 0..<50 {
            let burst = SplashDroplet.burst(
                at: CGPoint(x: 50, y: 40), direction: 1,
                home: CGPoint(x: 60, y: 43), born: 100, using: &generator
            )
            #expect((2...4).contains(burst.count))
            for drop in burst {
                #expect(drop.velocity.dx < 0)
                #expect(drop.velocity.dy < 0)
                #expect((1.8...3.6).contains(drop.radius))
                #expect((0.42...0.66).contains(drop.lifetime))
                #expect(drop.born >= 100 && drop.born <= 100.05)
                #expect(abs(drop.start.x - 50) <= 2)
            }
        }
    }

    @Test func burstsAreReproducibleWithASeedButVaryAcrossSeeds() {
        var first = SeededGenerator(state: 42)
        var second = SeededGenerator(state: 42)
        var third = SeededGenerator(state: 43)
        let a = SplashDroplet.burst(
            at: CGPoint(x: 50, y: 40), direction: 1,
            home: CGPoint(x: 60, y: 43), born: 100, using: &first
        )
        let b = SplashDroplet.burst(
            at: CGPoint(x: 50, y: 40), direction: 1,
            home: CGPoint(x: 60, y: 43), born: 100, using: &second
        )
        let c = SplashDroplet.burst(
            at: CGPoint(x: 50, y: 40), direction: 1,
            home: CGPoint(x: 60, y: 43), born: 100, using: &third
        )
        #expect(a == b)
        #expect(a != c)
    }

    @Test func burstEjectsBackwardFromTheTravelDirection() {
        var generator = SeededGenerator(state: 9)
        let burst = SplashDroplet.burst(
            at: CGPoint(x: 50, y: 40), direction: -1,
            home: CGPoint(x: 40, y: 43), born: 100, using: &generator
        )
        for drop in burst {
            #expect(drop.velocity.dx > 0)
        }
    }
}

//
//  ElasticDrag.swift
//  SeaBearKit
//
//  Elastic (rubber-band) drag damping with logarithmic falloff.
//

import CoreGraphics

/// Elastic (rubber-band) drag damping.
///
/// Within the comfort zone the raw translation passes through unchanged; beyond
/// it, movement follows `sign * (comfortZone + log(1 + excess) * 8)` so each
/// additional point of drag produces diminishing movement.
public enum ElasticDrag {
    /// Returns the damped offset for a raw translation value along one axis.
    public static func value(_ raw: CGFloat, comfortZone: CGFloat) -> CGFloat {
        let sign: CGFloat = raw < 0 ? -1 : 1
        let absValue = abs(raw)
        if absValue <= comfortZone {
            return raw
        }
        let excess = absValue - comfortZone
        return sign * (comfortZone + log(1 + excess) * 8)
    }
}

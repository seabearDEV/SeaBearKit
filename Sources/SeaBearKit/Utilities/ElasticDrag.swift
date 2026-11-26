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
/// it, movement follows `sign * (comfortZone + k * log(1 + excess / k))`, whose
/// slope is exactly 1 at the boundary and falls from there. The damped value
/// therefore never overtakes the raw drag: a rubber band, not a slingshot.
///
/// The earlier curve, `comfortZone + log(1 + excess) * 8`, had a slope of 8 at
/// the boundary and ran ahead of the finger for the first 26 pt of overshoot,
/// which showed up wherever the comfort zone is 0.
public enum ElasticDrag {
    /// Sets both the initial softness of the band and the scale of its falloff.
    private static let falloff: CGFloat = 8

    /// Returns the damped offset for a raw translation value along one axis.
    /// The magnitude of the result is never greater than the magnitude of `raw`.
    public static func value(_ raw: CGFloat, comfortZone: CGFloat) -> CGFloat {
        let sign: CGFloat = raw < 0 ? -1 : 1
        let absValue = abs(raw)
        if absValue <= comfortZone {
            return raw
        }
        let excess = absValue - comfortZone
        return sign * (comfortZone + falloff * log(1 + excess / falloff))
    }
}

//
//  ColorExtensions.swift
//  IOSLayouts
//
//  Color utilities for determining brightness and blending colors.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
typealias PlatformColor = UIColor
#elseif canImport(AppKit)
import AppKit
typealias PlatformColor = NSColor
#endif

extension Color {
    /// Determines if a color is considered "light" based on its brightness.
    /// Used for adaptive opacity adjustments in ghost nodes and other UI elements.
    var isLight: Bool {
        guard let components = PlatformColor(self).cgColor.components else { return false }

        // Handle grayscale colors (1-2 components)
        if components.count < 3 {
            let brightness = components[0]
            return brightness > 0.6
        }

        // RGB brightness calculation using standard luminance formula
        let brightness = (components[0] * 0.299 + components[1] * 0.587 + components[2] * 0.114)
        return brightness > 0.6
    }

    /// Blends this color with another color using a specified ratio.
    /// - Parameters:
    ///   - other: The color to blend with
    ///   - ratio: Blend ratio (0.0 = all this color, 1.0 = all other color)
    /// - Returns: The blended color
    func blend(with other: Color, ratio: Double) -> Color {
        let clampedRatio = max(0, min(1, ratio))

        guard let components1 = PlatformColor(self).cgColor.components,
              let components2 = PlatformColor(other).cgColor.components else {
            return self
        }

        // Ensure both colors have at least RGB components
        guard components1.count >= 3, components2.count >= 3 else {
            return self
        }

        let r = components1[0] * (1 - clampedRatio) + components2[0] * clampedRatio
        let g = components1[1] * (1 - clampedRatio) + components2[1] * clampedRatio
        let b = components1[2] * (1 - clampedRatio) + components2[2] * clampedRatio

        // Preserve alpha if available
        let a1 = components1.count > 3 ? components1[3] : 1.0
        let a2 = components2.count > 3 ? components2[3] : 1.0
        let a = a1 * (1 - clampedRatio) + a2 * clampedRatio

        return Color(red: r, green: g, blue: b, opacity: a)
    }
}

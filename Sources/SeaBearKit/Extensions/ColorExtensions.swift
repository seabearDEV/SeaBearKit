//
//  ColorExtensions.swift
//  SeaBearKit
//
//  Comprehensive color manipulation extensions for SwiftUI Color.
//  Provides luminance analysis, blending, brightness adjustment, and hex conversion.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
typealias PlatformColor = UIColor
#elseif canImport(AppKit)
import AppKit
typealias PlatformColor = NSColor
#endif

// MARK: - Resolved RGBA

/// Pre-resolved RGBA components for fast color blending without repeated platform color conversion.
/// Extract once with `Color.resolvedRGBA`, then blend efficiently with `ResolvedRGBA.blend(to:progress:)`.
public struct ResolvedRGBA: Sendable {
    public let red: CGFloat
    public let green: CGFloat
    public let blue: CGFloat
    public let alpha: CGFloat

    public init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    /// Blends this resolved color toward another using linear interpolation.
    /// - Parameters:
    ///   - end: The target color components
    ///   - progress: Interpolation factor (0.0 = this color, 1.0 = end color)
    /// - Returns: Blended SwiftUI Color
    public func blend(to end: ResolvedRGBA, progress: CGFloat) -> Color {
        let progress = min(1, max(0, progress))
        return Color(
            red: red + (end.red - red) * progress,
            green: green + (end.green - green) * progress,
            blue: blue + (end.blue - blue) * progress,
            opacity: alpha + (end.alpha - alpha) * progress
        )
    }
}

// MARK: - Color Extensions

extension Color {

    // MARK: - RGBA Resolution

    /// Resolves RGBA components once for use in repeated blend operations.
    /// More efficient than calling blend methods repeatedly when the source color doesn't change.
    public var resolvedRGBA: ResolvedRGBA {
        #if canImport(UIKit)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return ResolvedRGBA(red: red, green: green, blue: blue, alpha: alpha)
        #elseif canImport(AppKit)
        let nsColor = NSColor(self).usingColorSpace(.sRGB) ?? NSColor(self)
        return ResolvedRGBA(
            red: nsColor.redComponent,
            green: nsColor.greenComponent,
            blue: nsColor.blueComponent,
            alpha: nsColor.alphaComponent
        )
        #endif
    }

    // MARK: - Luminance

    /// Calculates perceptual luminance using the ITU-R BT.709 standard.
    /// Accounts for human eye sensitivity: green appears brightest, blue darkest.
    /// - Returns: Luminance value from 0.0 (black) to 1.0 (white)
    public var luminance: CGFloat {
        let rgba = resolvedRGBA
        return 0.299 * rgba.red + 0.587 * rgba.green + 0.114 * rgba.blue
    }

    /// Determines if color is light enough for dark text/UI elements.
    /// Default threshold of 0.6 provides good contrast for accessibility.
    public var isLight: Bool {
        isLight(threshold: 0.6)
    }

    /// Determines if color is light using a custom threshold.
    /// - Parameter threshold: Luminance threshold (default 0.6, lower = more colors considered light)
    /// - Returns: True if luminance exceeds threshold
    public func isLight(threshold: CGFloat = 0.6) -> Bool {
        luminance > threshold
    }

    /// Determines if color is dark enough for light text/UI elements.
    /// Default threshold of 0.3 ensures sufficient contrast for readability.
    public var isDark: Bool {
        isDark(threshold: 0.3)
    }

    /// Determines if color is dark using a custom threshold.
    /// - Parameter threshold: Luminance threshold (default 0.3, higher = more colors considered dark)
    /// - Returns: True if luminance is below threshold
    public func isDark(threshold: CGFloat = 0.3) -> Bool {
        luminance < threshold
    }

    /// Returns contrasting color (black or white) for text/patterns on this background.
    /// - Parameter threshold: Luminance threshold (default 0.5, use 0.6 for stricter contrast)
    /// - Returns: Black for light backgrounds, white for dark backgrounds
    public func contrastingColor(threshold: CGFloat = 0.5) -> Color {
        luminance > threshold ? .black : .white
    }

    // MARK: - Brightness Adjustment

    /// Adjusts brightness by adding/subtracting from RGB values.
    /// Positive values lighten, negative values darken.
    /// - Parameter amount: Brightness adjustment from -1.0 to 1.0
    /// - Returns: Color with adjusted brightness, clamped to valid range
    public func adjustedBrightness(_ amount: CGFloat) -> Color {
        let rgba = resolvedRGBA
        return Color(
            red: min(1, max(0, rgba.red + amount)),
            green: min(1, max(0, rgba.green + amount)),
            blue: min(1, max(0, rgba.blue + amount)),
            opacity: rgba.alpha
        )
    }

    // MARK: - Color Blending

    /// Performs smooth linear interpolation between two colors in RGB space.
    /// - Parameters:
    ///   - startColor: The initial color (progress = 0.0)
    ///   - endColor: The final color (progress = 1.0)
    ///   - progress: Interpolation factor clamped to 0.0-1.0 range
    /// - Returns: Blended color with interpolated RGBA values
    public static func blend(from startColor: Color, to endColor: Color, progress: CGFloat) -> Color {
        startColor.resolvedRGBA.blend(to: endColor.resolvedRGBA, progress: progress)
    }

    /// Blends this color with another color using a specified ratio.
    /// - Parameters:
    ///   - other: The color to blend with
    ///   - ratio: Blend ratio (0.0 = all this color, 1.0 = all other color)
    /// - Returns: The blended color
    public func blend(with other: Color, ratio: Double) -> Color {
        Color.blend(from: self, to: other, progress: ratio)
    }

    // MARK: - Hex Conversion

    /// Converts color to lowercase hex string format for serialization.
    /// - Returns: 6-character hex string with # prefix (e.g., "#ff0000")
    public func toHex() -> String {
        let rgba = resolvedRGBA
        let rgb = Int(rgba.red * 255) << 16 | Int(rgba.green * 255) << 8 | Int(rgba.blue * 255)
        return String(format: "#%06x", rgb)
    }

    /// Creates Color from hex string with flexible format support.
    /// Handles common hex formats: "#RGB", "RGB", "#RRGGBB", "RRGGBB", "#AARRGGBB"
    /// - Parameter hex: Hex color string (with or without # prefix)
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit) - expand to full range
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit) - most common format
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit) - includes alpha channel
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: // Invalid format - default to black
            (alpha, red, green, blue) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}

// MARK: - Gradient Luminance

/// A color-opacity pair for weighted luminance calculations.
/// Used when calculating effective luminance of gradient overlays.
public struct WeightedColor: Sendable {
    public let color: Color
    public let opacity: Double

    public init(color: Color, opacity: Double) {
        self.color = color
        self.opacity = opacity
    }
}

extension Array where Element == WeightedColor {
    /// Calculates the effective luminance of a gradient weighted by opacity.
    ///
    /// This is useful for determining if a gradient background is overall light or dark,
    /// which helps in choosing appropriate text colors or border styles.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let gradientColors: [WeightedColor] = [
    ///     WeightedColor(color: .blue, opacity: 0.5),
    ///     WeightedColor(color: .purple, opacity: 0.6),
    ///     WeightedColor(color: .pink, opacity: 0.7)
    /// ]
    ///
    /// let effectiveLuminance = gradientColors.weightedLuminance
    /// let textColor: Color = effectiveLuminance > 0.5 ? .black : .white
    /// ```
    ///
    /// - Returns: Weighted average luminance (0.0-1.0), or 0.5 if array is empty
    public var weightedLuminance: Double {
        guard !isEmpty else { return 0.5 }

        var totalWeighted = 0.0
        var totalOpacity = 0.0

        for weighted in self {
            let lum = weighted.color.luminance
            totalWeighted += lum * weighted.opacity
            totalOpacity += weighted.opacity
        }

        return totalOpacity > 0 ? totalWeighted / totalOpacity : 0.5
    }

    /// Returns a contrasting color (black or white) suitable for text on this gradient.
    /// - Parameter threshold: Luminance threshold (default 0.5)
    /// - Returns: Black for light gradients, white for dark gradients
    public func contrastingColor(threshold: Double = 0.5) -> Color {
        weightedLuminance > threshold ? .black : .white
    }
}

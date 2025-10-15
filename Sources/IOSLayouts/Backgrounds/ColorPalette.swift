//
//  ColorPalette.swift
//  IOSLayouts
//
//  Flexible color palette system for backgrounds and UI theming.
//  Supports gradient configuration with indices and opacity control.
//

import SwiftUI

/// A color palette with gradient configuration for background rendering.
public struct ColorPalette: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let colors: [Color]
    public let gradientIndices: [Int]
    public let gradientOpacities: [Double]

    /// Creates a color palette with gradient configuration.
    /// - Parameters:
    ///   - name: Display name of the palette
    ///   - colors: Array of colors in the palette
    ///   - gradientIndices: Indices of colors to use in gradient (default: uses first and last colors)
    ///   - gradientOpacities: Opacity values for each gradient color (default: 0.5 and 0.7)
    public init(
        name: String,
        colors: [Color],
        gradientIndices: [Int]? = nil,
        gradientOpacities: [Double]? = nil
    ) {
        self.id = name
        self.name = name
        self.colors = colors

        // Default gradient uses first and last colors
        if let indices = gradientIndices {
            self.gradientIndices = indices
        } else if colors.count >= 2 {
            self.gradientIndices = [0, colors.count - 1]
        } else {
            self.gradientIndices = [0]
        }

        // Default opacities provide subtle gradient effect
        self.gradientOpacities = gradientOpacities ?? [0.5, 0.7]
    }

    // MARK: - Sample Palettes

    /// A vibrant sunset palette with warm tones
    public static let sunset = ColorPalette(
        name: "Sunset",
        colors: [
            Color(red: 1.0, green: 0.4, blue: 0.4),   // Coral red
            Color(red: 1.0, green: 0.6, blue: 0.2),   // Orange
            Color(red: 1.0, green: 0.8, blue: 0.4),   // Golden yellow
            Color(red: 0.9, green: 0.5, blue: 0.7),   // Pink
            Color(red: 0.7, green: 0.3, blue: 0.8)    // Purple
        ],
        gradientIndices: [0, 2, 4],
        gradientOpacities: [0.4, 0.5, 0.6]
    )

    /// A calming ocean palette with cool blues and teals
    public static let ocean = ColorPalette(
        name: "Ocean",
        colors: [
            Color(red: 0.2, green: 0.4, blue: 0.8),   // Deep blue
            Color(red: 0.3, green: 0.6, blue: 0.9),   // Sky blue
            Color(red: 0.4, green: 0.8, blue: 0.8),   // Teal
            Color(red: 0.5, green: 0.7, blue: 0.9),   // Light blue
            Color(red: 0.3, green: 0.5, blue: 0.7)    // Ocean blue
        ],
        gradientIndices: [0, 2, 3],
        gradientOpacities: [0.5, 0.6, 0.4]
    )

    /// A natural forest palette with greens and earth tones
    public static let forest = ColorPalette(
        name: "Forest",
        colors: [
            Color(red: 0.2, green: 0.5, blue: 0.3),   // Dark green
            Color(red: 0.4, green: 0.7, blue: 0.4),   // Bright green
            Color(red: 0.6, green: 0.8, blue: 0.5),   // Light green
            Color(red: 0.5, green: 0.6, blue: 0.3),   // Olive
            Color(red: 0.4, green: 0.5, blue: 0.4)    // Sage
        ],
        gradientIndices: [0, 1, 2],
        gradientOpacities: [0.6, 0.5, 0.4]
    )

    /// A monochrome grayscale palette
    public static let monochrome = ColorPalette(
        name: "Monochrome",
        colors: [
            Color(white: 0.3),
            Color(white: 0.5),
            Color(white: 0.7),
            Color(white: 0.6),
            Color(white: 0.4)
        ],
        gradientIndices: [0, 2],
        gradientOpacities: [0.3, 0.5]
    )

    /// Default set of sample palettes
    public static let samplePalettes: [ColorPalette] = [
        .sunset,
        .ocean,
        .forest,
        .monochrome
    ]
}

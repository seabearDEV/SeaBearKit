//
//  GradientBackground.swift
//  IOSLayouts
//
//  A static gradient background with vignette effect for depth.
//  Extremely battery efficient with no animations.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// A static gradient background that adapts to light and dark modes.
/// Uses palette configuration to build a vertical gradient with vignette overlay.
public struct GradientBackground: View {
    let palette: ColorPalette
    @Environment(\.colorScheme) var colorScheme

    /// Creates a gradient background from a color palette.
    /// - Parameter palette: The color palette to use for gradient colors
    public init(palette: ColorPalette) {
        self.palette = palette
    }

    // MARK: - Gradient Colors

    /// Builds gradient colors using palette's gradient configuration
    private var gradientColors: [Color] {
        let colors = palette.colors

        // Build gradient colors using palette's gradient configuration
        var gradientColors: [Color] = []
        for (index, colorIndex) in palette.gradientIndices.enumerated() {
            // Ensure we have valid indices and corresponding opacities
            guard colorIndex < colors.count,
                  index < palette.gradientOpacities.count else { continue }

            let color = colors[colorIndex]
            let opacity = palette.gradientOpacities[index]
            gradientColors.append(color.opacity(opacity))
        }

        // Fallback if configuration resulted in no valid colors
        if gradientColors.isEmpty {
            if colors.count >= 2 {
                return [colors.first!.opacity(0.5), colors.last!.opacity(0.7)]
            } else {
                return colors.map { $0.opacity(0.6) }
            }
        }

        return gradientColors
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            // Base system background for proper light/dark mode support
            #if canImport(UIKit)
            Color(uiColor: .systemBackground)
            #else
            Color(nsColor: .windowBackgroundColor)
            #endif

            // Vertical gradient overlay
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .top,
                endPoint: .bottom
            )

            // Vignette overlay for depth (adapts to light/dark mode)
            RadialGradient(
                colors: [
                    Color.clear,
                    colorScheme == .dark
                        ? Color.black.opacity(0.25)  // Dark mode: darker edges for depth
                        : Color.black.opacity(0.15)  // Light mode: subtle shadow
                ],
                center: .center,
                startRadius: 200,
                endRadius: 500
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Preview

#Preview("Gradient Backgrounds") {
    VStack(spacing: 0) {
        ForEach(ColorPalette.samplePalettes) { palette in
            GradientBackground(palette: palette)
                .frame(height: 200)
                .overlay(
                    Text(palette.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                )
        }
    }
}

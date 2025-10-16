//
//  PersistentBackground.swift
//  IOSLayouts
//
//  Composable background component that combines gradient backgrounds.
//  The main reusable background system for persistent navigation.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// Configuration options for the persistent background
public struct BackgroundConfiguration: Sendable {
    /// Whether to show the gradient background
    public var showGradient: Bool

    /// Creates a background configuration with specified options.
    /// - Parameters:
    ///   - showGradient: Enable gradient background (default: true)
    public init(showGradient: Bool = true) {
        self.showGradient = showGradient
    }

    /// Preset configuration with gradient background
    public static let standard = BackgroundConfiguration(showGradient: true)

    /// Preset configuration for minimal background (system background only)
    public static let minimal = BackgroundConfiguration(showGradient: false)
}

/// A persistent background with a gradient effect.
/// Designed to sit behind NavigationStack and remain visible during navigation transitions.
public struct PersistentBackground: View {
    let palette: ColorPalette
    let configuration: BackgroundConfiguration

    /// Creates a persistent background with the specified palette and configuration.
    /// - Parameters:
    ///   - palette: The color palette to use
    ///   - configuration: Background configuration options (default: .standard)
    public init(palette: ColorPalette, configuration: BackgroundConfiguration = .standard) {
        self.palette = palette
        self.configuration = configuration
    }

    public var body: some View {
        if configuration.showGradient {
            GradientBackground(palette: palette)
        } else {
            // Fallback to system background
            Group {
                #if canImport(UIKit)
                Color(uiColor: .systemBackground)
                #else
                Color(nsColor: .windowBackgroundColor)
                #endif
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - View Extension

extension View {
    /// Applies a persistent gradient background to the view.
    /// - Parameters:
    ///   - palette: The color palette to use
    ///   - configuration: Background configuration options (default: .standard)
    /// - Returns: The view with a persistent background applied
    public func persistentBackground(
        palette: ColorPalette,
        configuration: BackgroundConfiguration = .standard
    ) -> some View {
        self.background(
            PersistentBackground(palette: palette, configuration: configuration)
        )
    }
}

// MARK: - Preview

#Preview("Background Configurations") {
    VStack(spacing: 0) {
        // Standard gradient background
        ZStack {
            PersistentBackground(palette: .sunset, configuration: .standard)
            Text("Standard Background")
                .font(.title2)
                .fontWeight(.semibold)
        }
        .frame(height: 400)

        // Minimal (system background)
        ZStack {
            PersistentBackground(palette: .forest, configuration: .minimal)
            Text("Minimal Background")
                .font(.title2)
                .fontWeight(.semibold)
        }
        .frame(height: 400)
    }
}

//
//  SeaBearKit.swift
//  SeaBearKit
//
//  Main module file for SeaBearKit library.
//  A collection of SwiftUI layouts and reusable UI components.
//

import SwiftUI

/// SeaBearKit - SwiftUI layouts and components
///
/// This library provides layout patterns and utilities for iOS applications.
///
/// ## Core Components
///
/// ### Persistent Background System
/// - `PersistentBackground` - Gradient background component
/// - `PersistentBackgroundNavigation` - NavigationStack wrapper that maintains background during transitions
/// - `GradientBackground` - Static gradient background with vignette effect
///
/// ### Automatic Navigation (Recommended)
/// - `PersistentNavigationLink` - Automatic NavigationLink that auto-applies background transparency
/// - `.persistentNavigationDestination(for:)` - Auto-wrapping value-based navigation
/// - `.persistentNavigationDestination(item:)` - Auto-wrapping optional binding navigation
/// - `.persistentNavigationDestination(isPresented:)` - Auto-wrapping boolean navigation
///
/// ### Manual Navigation (Advanced)
/// - `.clearNavigationBackground()` - Manual modifier for precise control
///
/// ### View Modifiers
/// - `.if(_:transform:)` - Conditional view modifier for cleaner code
/// - `.glassShadow(isPressed:intensity:)` - Unified shadow system for Liquid Glass UI
/// - `.adaptiveCornerRadius(_:size:)` - Proportional corner radius system
/// - `CornerRadiusStyle` - Predefined corner radius presets
/// - `ShadowIntensity` - Shadow intensity levels (.subtle, .regular, .prominent)
///
/// ### Color System
/// - `ColorPalette` - Flexible color palette with gradient configuration
/// - Sample palettes: `.sunset`, `.ocean`, `.forest`, `.monochrome`
///
/// ### Color Utilities
/// - `Color.luminance` - Perceptual brightness (ITU-R BT.709)
/// - `Color.isLight` / `Color.isDark` - Threshold-based checks (with parameterized variants)
/// - `WeightedColor` / `[WeightedColor].weightedLuminance` - Gradient luminance calculation
/// - `Color.contrastingColor()` - Returns black or white for text
/// - `Color.adjustedBrightness(_:)` - Lighten or darken colors
/// - `Color.blend(from:to:progress:)` - Linear color interpolation
/// - `Color.toHex()` / `Color(hex:)` - Hex string conversion
/// - `ResolvedRGBA` - Pre-resolved components for efficient blending
///
/// ### View Modifiers
/// - `.if(_:transform:)` - Conditional modifier application
/// - `.adaptiveInnerBorder(color:cornerRadius:)` - Luminance-aware highlight border
/// - `.onShake(perform:)` - Shake gesture detection (iOS only)
///
/// ### Utilities
/// - `HapticHelper` - Low-latency haptic feedback (iOS only)
/// - `Int.formattedAsTime` / `Double.formattedAsTime` - MM:SS formatting
///
/// ### Configuration
/// - `BackgroundConfiguration` - Preset configurations: `.standard`, `.minimal`
///
/// ## Quick Start
///
/// ```swift
/// import SeaBearKit
///
/// @main
/// struct MyApp: App {
///     var body: some Scene {
///         WindowGroup {
///             PersistentBackgroundNavigation(palette: .sunset) {
///                 ContentView()
///             }
///         }
///     }
/// }
///
/// // In your views - Automatic (Recommended)
/// PersistentNavigationLink("Details") {
///     DetailView()  // Background persists automatically!
/// }
///
/// // Color utilities
/// let textColor = backgroundColor.contrastingColor()
/// let blended = Color.blend(from: .red, to: .blue, progress: 0.5)
///
/// // Haptic feedback
/// HapticHelper.impact(.medium)
/// HapticHelper.notification(.success)
/// ```
///
public struct SeaBearKit {
    /// Library version
    public static let version = "1.5.0"

    /// Library name
    public static let name = "SeaBearKit"

    /// Minimum iOS version supported
    public static let minimumIOSVersion = "17.0"

    /// Recommended iOS version for optimal experience
    public static let recommendedIOSVersion = "18.0"
}

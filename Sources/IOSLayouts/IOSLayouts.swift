//
//  IOSLayouts.swift
//  IOSLayouts
//
//  Main module file for IOSLayouts library.
//  A collection of production-ready SwiftUI layouts and reusable UI components.
//

import SwiftUI

/// IOSLayouts - Production-ready SwiftUI layouts and components
///
/// This library provides battle-tested layout patterns extracted from real-world iOS applications.
///
/// ## Core Components
///
/// ### Persistent Background System
/// - `PersistentBackground` - Gradient background component
/// - `PersistentBackgroundNavigation` - NavigationStack wrapper that maintains background during transitions
/// - `GradientBackground` - Static gradient background with vignette effect
///
/// ### Color System
/// - `ColorPalette` - Flexible color palette with gradient configuration
/// - Sample palettes: `.sunset`, `.ocean`, `.forest`, `.monochrome`
///
/// ### Configuration
/// - `BackgroundConfiguration` - Preset configurations: `.standard`, `.minimal`
///
/// ## Quick Start
///
/// ```swift
/// import IOSLayouts
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
/// ```
///
public struct IOSLayouts {
    /// Library version
    public static let version = "1.0.0"

    /// Library name
    public static let name = "IOSLayouts"
}

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
/// This library provides layout patterns for iOS applications.
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
/// // Or Manual (Advanced)
/// NavigationLink("Details") {
///     DetailView()
///         .clearNavigationBackground()
/// }
/// ```
///
public struct SeaBearKit {
    /// Library version
    public static let version = "1.2.0"

    /// Library name
    public static let name = "SeaBearKit"

    /// Minimum iOS version supported
    public static let minimumIOSVersion = "17.0"

    /// Recommended iOS version for optimal experience
    public static let recommendedIOSVersion = "18.0"
}

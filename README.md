# IOSLayouts

A collection of production-ready SwiftUI layout patterns and UI components for iOS development.

## Core Feature: Persistent Background Navigation

The **PersistentBackgroundNavigation** component maintains consistent backgrounds across NavigationStack transitions.

This pattern was developed through extensive iteration to address SwiftUI's navigation background consistency issues.

## Features

- **Persistent Background System**: NavigationStack wrapper that maintains backgrounds during transitions
- **Gradient Backgrounds**: Configurable gradients with vignette effects (iOS 18+ Liquid Glass compatible)
- **Color Palettes**: Extensible palette system with nine built-in themes
- **Performance Optimized**: Static gradients with minimal battery impact
- **Appearance Adaptive**: Automatic light/dark mode support
- **Material Integration**: Compatible with iOS 18+ material system
- **Pure SwiftUI**: No external dependencies

## Quick Start

```swift
import SwiftUI
import IOSLayouts

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            PersistentBackgroundNavigation(palette: .sunset) {
                ContentView()
            }
        }
    }
}
```

This provides a gradient background that persists across all navigation transitions.

**Important**: Every destination view in your navigation hierarchy must include:
```swift
.containerBackground(for: .navigation) { Color.clear }
```

Refer to **[IMPORTANT.md](IMPORTANT.md)** for implementation details.

## Requirements

- iOS 18.0+ (required for `.containerBackground(for: .navigation)` API)
- Swift 6.0+
- Xcode 16.0+

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/seabearDEV/ios-layouts.git", from: "1.0.0")
]
```

Or in Xcode: File → Add Package Dependencies → Enter repository URL

## Color Palettes

The library includes nine built-in palettes and supports custom palette creation:

```swift
// Built-in palettes
.sunset         // Warm tones: coral, orange, yellow
.ocean          // Cool blues and teals
.forest         // Natural greens and earth tones
.monochrome     // Grayscale
.midnight       // Dark blues and purples (for dark themes)
.cherryBlossom  // Soft pinks and roses
.autumn         // Warm oranges, reds, and browns
.lavender       // Calming purple and blue tones
.mint           // Fresh greens and blues

// Custom palette
ColorPalette(
    name: "Custom",
    colors: [.red, .orange, .yellow, .green, .blue],
    gradientIndices: [0, 2, 4],
    gradientOpacities: [0.4, 0.5, 0.6]
)
```

## Configuration Modes

Two configuration modes are available:

```swift
// Standard (gradient background)
PersistentBackgroundNavigation(palette: .sunset)

// Minimal (system background only)
PersistentBackgroundNavigation.minimal(palette: .forest)
```

## Documentation

- **[Usage Guide](USAGE.md)** - Comprehensive examples and best practices
- **[Architecture](ARCHITECTURE.md)** - Technical details and design decisions
- **[Liquid Glass Compliance](LIQUID_GLASS.md)** - iOS 18+ Liquid Glass design system integration
- **[IMPORTANT](IMPORTANT.md)** - Critical requirement for all navigation views
- **[Demo App](Sources/Demo/)** - Full working example showcasing all features

## Problem Statement

Standard SwiftUI NavigationStack implementations create their own backgrounds that can change inconsistently during transitions. This library addresses the issue through a layered approach:

```swift
ZStack {
    PersistentBackground(palette: palette)  // Lives outside navigation lifecycle

    NavigationStack {
        Content()
            .containerBackground(for: .navigation) {
                Color.clear  // Makes navigation transparent
            }
    }
}
```

This approach ensures consistent background rendering throughout navigation transitions.

## Project Origins

This pattern was developed through iterative refinement to resolve background consistency issues in SwiftUI navigation. Key development milestones:

- Resolved background consistency during color palette transitions
- Centralized background rendering and improved gradient visibility
- Removed LinearGradient tint overlays to improve navigation rendering
- Standardized navigation transitions and view backgrounds

## Demo

To view interactive previews:

```bash
git clone https://github.com/seabearDEV/ios-layouts.git
cd ios-layouts
open Package.swift
```

Navigate to `PersistentBackgroundNavigation.swift` and open Canvas (⌥⌘↩) for interactive preview.

Complete demo instructions available in **[DEMO.md](DEMO.md)**

## Contributing

Contributions should maintain:

- iOS 18+ compatibility (`.containerBackground(for: .navigation)` API requirement)
- Swift 6 strict concurrency compliance
- Performance characteristics (battery impact testing required)
- Light and dark mode support
- Documentation updates for API changes

## License

MIT License - see [LICENSE](LICENSE) file for details

## Author

**Kory Hoopes** - [seabearDEV](https://github.com/seabearDEV)

## Acknowledgments

This library was developed to address production challenges encountered in iOS development. All components have been tested in production environments.

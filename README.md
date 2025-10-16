# SeaBearKit

[![Swift Version](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2017+%20|%20macOS%2014+-blue.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![SPM Compatible](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)](https://swift.org/package-manager)

A collection of production-ready SwiftUI layout patterns and UI components for iOS development.

## Core Feature: Persistent Background Navigation

The **PersistentBackgroundNavigation** component maintains consistent backgrounds across NavigationStack transitions.

This pattern was developed through extensive iteration to address SwiftUI's navigation background consistency issues.

## Features

- **Zero-Friction Navigation**: Automatic background persistence without manual modifiers
- **Persistent Background System**: NavigationStack wrapper that maintains backgrounds during transitions
- **Flexible API**: Choose automatic convenience wrappers or manual control
- **Gradient Backgrounds**: Configurable gradients with vignette effects (iOS 18+ Liquid Glass compatible)
- **Color Palettes**: Extensible palette system with nine built-in themes
- **Performance Optimized**: Static gradients with minimal battery impact
- **Appearance Adaptive**: Automatic light/dark mode support
- **Material Integration**: Compatible with iOS 18+ material system
- **Pure SwiftUI**: No external dependencies

## Quick Start

### 1. Wrap your app in PersistentBackgroundNavigation

```swift
import SwiftUI
import SeaBearKit

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

### 2. Use navigation in your views

**Automatic (Recommended)** - Zero friction, just works:
```swift
PersistentNavigationLink("View Details") {
    DetailView()  // Background persists automatically!
}
```

**Manual (Advanced)** - For precise control:
```swift
NavigationLink("View Details") {
    DetailView()
        .clearNavigationBackground()
}
```

Both approaches work perfectly - choose what fits your style!

## Requirements

- iOS 17.0+ (iOS 18+ recommended for best experience)
- Swift 6.0+
- Xcode 15.0+

**Note**: While iOS 17 is supported, iOS 18+ provides the optimal experience using `.containerBackground(for: .navigation)`. iOS 17 uses a fallback approach that works well in most cases.

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/seabearDEV/ios-layouts.git", from: "1.0.0")
]
```

Or in Xcode: File → Add Package Dependencies → Enter repository URL

## Navigation Approaches

SeaBearKit provides flexibility to match your coding style:

### Automatic (Recommended for most cases)

Use `PersistentNavigationLink` for zero-friction navigation:

```swift
PersistentNavigationLink("Details") {
    DetailView()
}

// Custom label
PersistentNavigationLink {
    DetailView()
} label: {
    HStack {
        Image(systemName: "star")
        Text("Featured")
    }
}
```

Value-based navigation:
```swift
NavigationStack {
    List(items) { item in
        Button(item.name) {
            selectedItem = item
        }
    }
}
.persistentNavigationDestination(for: Item.self) { item in
    ItemDetailView(item: item)
}
```

### Manual (Advanced control)

Use standard `NavigationLink` with `.clearNavigationBackground()`:

```swift
NavigationLink("Settings") {
    SettingsView()
        .clearNavigationBackground()
        .customModifier()  // Add your own modifiers
}
```

### When to use each:

- **Automatic**: Large apps, team projects, when you want it to "just work"
- **Manual**: Edge cases, when you need additional modifiers, precise control

Both approaches coexist perfectly - use what makes sense for each screen.

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

## Development

### Running Tests

```bash
# Run all tests
swift test

# Build the package
swift build

# Open in Xcode
open Package.swift
```

### Testing in Your Project

Add the package locally for testing:

```swift
// In your Package.swift
dependencies: [
    .package(path: "/path/to/ios-layouts")
]
```

Or use Xcode: **File → Add Package Dependencies → Add Local**

## Contributing

Contributions are welcome! Please read **[CONTRIBUTING.md](CONTRIBUTING.md)** for:
- Development setup
- Code standards
- Testing requirements
- Pull request process

All contributions should maintain:
- iOS 17+ compatibility (iOS 18+ for optimal experience)
- Swift 6 strict concurrency compliance
- All tests passing (`swift test`)
- Documentation updates for API changes
- CHANGELOG.md updates

## License

MIT License - see [LICENSE](LICENSE) file for details

## Author

**Kory Hoopes** - [seabearDEV](https://github.com/seabearDEV)

## Acknowledgments

This library was developed to address production challenges encountered in iOS development. All components have been tested in production environments.

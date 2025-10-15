# Quick Start Guide

IOSLayouts integration guide.

## Installation

Add to your Xcode project: **File → Add Package Dependencies**

```
https://github.com/seabearDEV/ios-layouts.git
```

## Basic Usage

Replace your app's entry point with this:

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

This provides a persistent gradient background across navigation transitions.

## Choose a Palette

```swift
.sunset         // Warm tones (default)
.ocean          // Cool blues
.forest         // Natural greens
.monochrome     // Grayscale
.midnight       // Dark blues and purples
.cherryBlossom  // Soft pinks
.autumn         // Warm oranges and reds
.lavender       // Calming purples
.mint           // Fresh greens
```

## Background Modes

```swift
// Standard (gradient background)
PersistentBackgroundNavigation(palette: .sunset)

// Minimal (system background only)
PersistentBackgroundNavigation.minimal(palette: .forest)
```

## Custom Palette

```swift
let myPalette = ColorPalette(
    name: "Brand",
    colors: [.red, .orange, .yellow, .green, .blue],
    gradientIndices: [0, 2, 4],
    gradientOpacities: [0.4, 0.5, 0.6]
)

PersistentBackgroundNavigation(palette: myPalette) {
    ContentView()
}
```

## Dynamic Switching

```swift
@State private var palette: ColorPalette = .sunset

var body: some Scene {
    WindowGroup {
        PersistentBackgroundNavigation(palette: palette) {
            ContentView(onPaletteChange: { newPalette in
                withAnimation(.easeInOut(duration: 0.3)) {
                    palette = newPalette
                }
            })
        }
    }
}
```

## Requirements

- iOS 18.0+
- Swift 6.0+
- Xcode 16.0+

## Next Steps

- **[Full Usage Guide](USAGE.md)** - Comprehensive examples and patterns
- **[Architecture](ARCHITECTURE.md)** - Technical details and design decisions
- **[Demo App](Sources/Demo/)** - Complete working example

## Technical Overview

Standard SwiftUI NavigationStack implementations can cause background flickering during transitions. This library addresses the issue through layered architecture:

```swift
ZStack {
    PersistentBackground(palette: palette)  // Outside navigation lifecycle

    NavigationStack {
        Content()
            .containerBackground(for: .navigation) {
                Color.clear  // Transparent container = no flicker
            }
    }
}
```

This pattern was refined through production use.

## Support

- GitHub Issues: [github.com/seabearDEV/ios-layouts/issues](https://github.com/seabearDEV/ios-layouts/issues)

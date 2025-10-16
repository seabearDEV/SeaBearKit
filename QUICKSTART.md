# Quick Start Guide

SeaBearKit integration guide.

## Installation

Add to your Xcode project: **File → Add Package Dependencies**

```
https://github.com/seabearDEV/SeaBearKit.git
```

## Basic Usage

Replace your app's entry point with this:

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

This provides a persistent gradient background across navigation transitions.

## Navigation

SeaBearKit offers two ways to handle navigation - choose what fits your style:

### Automatic (Recommended)

Use `PersistentNavigationLink` for zero-friction navigation:

```swift
import SeaBearKit

struct ContentView: View {
    var body: some View {
        VStack {
            PersistentNavigationLink("View Profile") {
                ProfileView()  // Background persists automatically!
            }

            // Custom label
            PersistentNavigationLink {
                SettingsView()
            } label: {
                Label("Settings", systemImage: "gear")
            }
        }
        .navigationTitle("Home")
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
    ItemDetailView(item: item)  // Automatic!
}
```

### Manual (Advanced)

Use standard SwiftUI with `.clearNavigationBackground()`:

```swift
NavigationLink("Advanced Settings") {
    AdvancedSettingsView()
        .clearNavigationBackground()
}
```

Both approaches work together - mix and match as needed!

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

## Custom Backgrounds

Use any SwiftUI view as a background:

```swift
PersistentBackgroundNavigation {
    Image("hero-background")
        .resizable()
        .aspectRatio(contentMode: .fill)
        .ignoresSafeArea()
} content: {
    ContentView()
}
```

Works with: images, videos, patterns, animated gradients, or any custom view.

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

- iOS 17.0+ (iOS 18+ recommended)
- Swift 6.0+
- Xcode 15.0+

**Platform Note**: iOS 18+ provides the best experience. iOS 17 uses a fallback approach that works well for most use cases.

## Next Steps

- **[Full Usage Guide](USAGE.md)** - Comprehensive examples and patterns
- **[Architecture](ARCHITECTURE.md)** - Technical details and design decisions
- **[Demo App](Sources/Demo/)** - Complete working example

## Technical Overview

Standard SwiftUI NavigationStack implementations can cause background inconsistencies during transitions. This library addresses the issue through layered architecture:

```swift
ZStack {
    PersistentBackground(palette: palette)  // Outside navigation lifecycle

    NavigationStack {
        Content()
            .containerBackground(for: .navigation) {
                Color.clear  // Transparent container = consistent rendering
            }
    }
}
```

This pattern was refined through production use.

## Support

- GitHub Issues: [github.com/seabearDEV/SeaBearKit/issues](https://github.com/seabearDEV/SeaBearKit/issues)

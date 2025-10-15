# IOSLayouts Usage Guide

Production-ready SwiftUI layout patterns for iOS development. This guide documents the **PersistentBackgroundNavigation** system, which maintains consistent backgrounds across navigation transitions without flickering.

## Installation

### Swift Package Manager

Add IOSLayouts to your project:

```swift
dependencies: [
    .package(url: "https://github.com/seabearDEV/ios-layouts.git", from: "1.0.0")
]
```

Then import it in your Swift files:

```swift
import IOSLayouts
```

## Quick Start

Wrap your root view in `PersistentBackgroundNavigation`:

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

This configuration provides a persistent gradient background across all navigation transitions.

## Core Components

### PersistentBackgroundNavigation

NavigationStack wrapper that maintains a persistent background layer.

```swift
PersistentBackgroundNavigation(
    palette: .sunset,
    configuration: .standard
) {
    YourRootView()
}
```

**Convenience initializer:**

```swift
// Minimal mode (system background only)
PersistentBackgroundNavigation.minimal(palette: .forest) {
    YourRootView()
}
```

### Color Palettes

IOSLayouts includes several built-in palettes:

```swift
ColorPalette.sunset      // Warm tones: coral, orange, yellow, pink, purple
ColorPalette.ocean       // Cool blues and teals
ColorPalette.forest      // Natural greens and earth tones
ColorPalette.monochrome  // Grayscale
```

**Creating custom palettes:**

```swift
let customPalette = ColorPalette(
    name: "Custom",
    colors: [
        Color.red,
        Color.orange,
        Color.yellow,
        Color.green,
        Color.blue
    ],
    gradientIndices: [0, 2, 4],        // Use 1st, 3rd, and 5th colors
    gradientOpacities: [0.4, 0.5, 0.6] // With these opacities
)
```

### Background Configuration

Control what background is displayed:

```swift
// Standard (gradient background)
BackgroundConfiguration.standard

// Minimal (system background)
BackgroundConfiguration.minimal

// Custom configuration
BackgroundConfiguration(showGradient: true)
```

## Advanced Usage

### Dynamic Palette Switching

You can switch palettes dynamically with animations:

```swift
@State private var currentPalette: ColorPalette = .sunset

var body: some View {
    PersistentBackgroundNavigation(palette: currentPalette) {
        ContentView(onPaletteChange: { newPalette in
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPalette = newPalette
            }
        })
    }
}
```

### Using Individual Components

If you want more control, you can use the components separately:

```swift
// Just the gradient
GradientBackground(palette: .sunset)

// Persistent background
PersistentBackground(palette: .forest, configuration: .standard)

// Apply as a view modifier
SomeView()
    .persistentBackground(palette: .sunset)
```

### Implementation Pattern

The flicker-free approach uses a layered structure:

```swift
ZStack {
    // Background layer (behind everything)
    PersistentBackground(palette: palette, configuration: configuration)

    // Navigation layer (transparent container)
    NavigationStack {
        YourContent()
            .containerBackground(for: .navigation) {
                Color.clear  // <-- This is critical!
            }
    }
}
```

The `.containerBackground(for: .navigation) { Color.clear }` modifier renders the NavigationStack transparent, exposing the persistent background layer while eliminating flicker during transitions.

## Best Practices

### Performance

- **Standard mode** (`.standard`): Beautiful gradient background with minimal battery impact
- **Minimal mode** (`.minimal`): System background only. Best for maximum simplicity.

### Accessibility

The backgrounds automatically adapt to:
- Light and dark mode (proper contrast maintained)
- Dynamic Type (all text scales appropriately)
- Color scheme preferences

### Design Considerations

1. **Brand Alignment**: Select palettes that complement your application's visual identity
2. **Appearance Testing**: Verify rendering in both light and dark modes
3. **Visual Balance**: Gradients should enhance content without overwhelming it

## Examples

### Simple Menu Screen

```swift
struct MenuView: View {
    var body: some View {
        List {
            NavigationLink("Play") { GameView() }
            NavigationLink("Settings") { SettingsView() }
            NavigationLink("About") { AboutView() }
        }
        .navigationTitle("Main Menu")
    }
}
```

### Deep Navigation

```swift
struct RootView: View {
    var body: some View {
        List(categories) { category in
            NavigationLink(category.name) {
                CategoryView(category: category)
            }
        }
    }
}

struct CategoryView: View {
    let category: Category

    var body: some View {
        List(category.items) { item in
            NavigationLink(item.name) {
                DetailView(item: item)
            }
        }
        .navigationTitle(category.name)
    }
}
```

The persistent background maintains consistency across all navigation hierarchy levels.

## Troubleshooting

### Background Flicker During Navigation

Ensure `PersistentBackgroundNavigation` is used rather than manual `NavigationStack` creation. The wrapper applies the required `.containerBackground(for: .navigation)` modifier.

**Note**: All destination views must include `.containerBackground(for: .navigation) { Color.clear }`. Refer to **[IMPORTANT.md](IMPORTANT.md)** for implementation details.

### Gradient Not Visible

Verify configuration is set to `.standard` rather than `.minimal`:

```swift
PersistentBackgroundNavigation(palette: .ocean) {
    ContentView()
}
```

## Development History

This pattern was developed through iterative refinement to resolve NavigationStack background flickering issues.

Key development milestones:
- Resolved background flicker during color palette transitions
- Centralized background rendering and improved gradient visibility
- Removed LinearGradient tint overlays to eliminate navigation artifacts

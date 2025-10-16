# SeaBearKit Usage Guide

Production-ready SwiftUI layout patterns for iOS development. This guide documents the **PersistentBackgroundNavigation** system, which maintains consistent backgrounds across navigation transitions.

## Installation

### Swift Package Manager

Add SeaBearKit to your project:

```swift
dependencies: [
    .package(url: "https://github.com/seabearDEV/SeaBearKit.git", from: "1.0.0")
]
```

Then import it in your Swift files:

```swift
import SeaBearKit
```

## Quick Start

Wrap your root view in `PersistentBackgroundNavigation`:

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

SeaBearKit includes nine built-in palettes:

```swift
ColorPalette.sunset         // Warm tones: coral, orange, yellow, pink, purple
ColorPalette.ocean          // Cool blues and teals
ColorPalette.forest         // Natural greens and earth tones
ColorPalette.monochrome     // Grayscale
ColorPalette.midnight       // Dark blues and purples (for dark themes)
ColorPalette.cherryBlossom  // Soft pinks and roses
ColorPalette.autumn         // Warm oranges, reds, and browns
ColorPalette.lavender       // Calming purple and blue tones
ColorPalette.mint           // Fresh greens and blues
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

## Navigation Patterns

SeaBearKit provides flexible navigation options to match your coding style and project needs.

### Automatic Navigation (Recommended)

Use convenience wrappers that automatically handle background persistence:

#### PersistentNavigationLink

Drop-in replacement for `NavigationLink`:

```swift
// Simple text label
PersistentNavigationLink("View Profile") {
    ProfileView()  // Background persists automatically!
}

// Custom label
PersistentNavigationLink {
    SettingsView()
} label: {
    Label("Settings", systemImage: "gear")
        .foregroundStyle(.primary)
}
```

#### Value-Based Navigation

For programmatic navigation with state:

```swift
struct ItemListView: View {
    @State private var selectedItem: Item?

    var body: some View {
        NavigationStack {
            List(items) { item in
                Button(item.name) {
                    selectedItem = item
                }
            }
        }
        .persistentNavigationDestination(for: Item.self) { item in
            ItemDetailView(item: item)  // Automatic background!
        }
    }
}
```

#### Boolean-Based Navigation

For modal-style navigation:

```swift
struct ContentView: View {
    @State private var showingDetail = false

    var body: some View {
        Button("Show Details") {
            showingDetail = true
        }
        .persistentNavigationDestination(isPresented: $showingDetail) {
            DetailView()  // Automatic background!
        }
    }
}
```

### Manual Navigation (Advanced Control)

Use standard SwiftUI navigation with explicit background control:

```swift
NavigationLink("Advanced Settings") {
    AdvancedSettingsView()
        .clearNavigationBackground()  // Manual control
        .customModifier()               // Add your modifiers
}
```

### When to Use Each Approach

**Automatic (PersistentNavigationLink)**
- ✅ Large apps with many navigation screens
- ✅ Team projects (junior-friendly, can't forget)
- ✅ When you want it to "just work"
- ✅ Reduces boilerplate

**Manual (.clearNavigationBackground())**
- ✅ Edge cases requiring precise control
- ✅ When adding custom modifiers to destinations
- ✅ Advanced customization scenarios
- ✅ Existing codebases (minimal changes)

**Mix and Match**
Both approaches work together perfectly:

```swift
struct MenuView: View {
    var body: some View {
        VStack {
            // Automatic for most screens
            PersistentNavigationLink("Profile") {
                ProfileView()
            }

            // Manual for special case
            NavigationLink("Advanced") {
                AdvancedView()
                    .clearNavigationBackground()
                    .customSetup()
            }
        }
    }
}
```

## Advanced Usage

### Custom Backgrounds

Use any SwiftUI view as a persistent background:

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

Examples:

```swift
// Video background
PersistentBackgroundNavigation {
    VideoPlayerView(url: backgroundVideoURL)
        .ignoresSafeArea()
} content: {
    ContentView()
}

// Custom pattern
PersistentBackgroundNavigation {
    ZStack {
        Color.indigo
        GeometryReader { geometry in
            // Custom drawing code
        }
    }
    .ignoresSafeArea()
} content: {
    ContentView()
}

// Animated gradient
PersistentBackgroundNavigation {
    AnimatedGradientView()
        .ignoresSafeArea()
} content: {
    ContentView()
}
```

The persistent architecture works with any SwiftUI view - your background stays consistent across all navigation transitions.

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

The consistent rendering approach uses a layered structure:

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

The `.containerBackground(for: .navigation) { Color.clear }` modifier renders the NavigationStack transparent, exposing the persistent background layer and ensuring consistent rendering during transitions.

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

### Simple Menu Screen (Automatic)

```swift
struct MenuView: View {
    var body: some View {
        List {
            PersistentNavigationLink("Play") { GameView() }
            PersistentNavigationLink("Settings") { SettingsView() }
            PersistentNavigationLink("About") { AboutView() }
        }
        .navigationTitle("Main Menu")
    }
}
```

### Deep Navigation (Automatic)

```swift
struct RootView: View {
    var body: some View {
        List(categories) { category in
            PersistentNavigationLink(category.name) {
                CategoryView(category: category)
            }
        }
    }
}

struct CategoryView: View {
    let category: Category

    var body: some View {
        List(category.items) { item in
            PersistentNavigationLink(item.name) {
                DetailView(item: item)
            }
        }
        .navigationTitle(category.name)
    }
}
```

The persistent background maintains consistency across all navigation hierarchy levels - no manual modifiers needed!

### Value-Based List Navigation

```swift
struct ProductListView: View {
    @State private var products: [Product] = [...]
    @State private var selectedProduct: Product?

    var body: some View {
        List(products) { product in
            Button {
                selectedProduct = product
            } label: {
                ProductRowView(product: product)
            }
        }
        .persistentNavigationDestination(for: Product.self) { product in
            ProductDetailView(product: product)
        }
    }
}
```

### Manual Approach (Advanced)

For cases where you need precise control:

```swift
struct AdvancedMenuView: View {
    var body: some View {
        List {
            NavigationLink("Standard") {
                StandardView()
                    .clearNavigationBackground()
            }

            NavigationLink("Custom") {
                CustomView()
                    .clearNavigationBackground()
                    .customModifier()
                    .specialBehavior()
            }
        }
    }
}
```

## Troubleshooting

### Background Inconsistency During Navigation

**Quick Fix**: Use `PersistentNavigationLink` instead of `NavigationLink`:

```swift
// ❌ May lose background
NavigationLink("Details") {
    DetailView()
}

// ✅ Background persists automatically
PersistentNavigationLink("Details") {
    DetailView()
}
```

**Alternative**: If using standard `NavigationLink`, add `.clearNavigationBackground()` to each destination view:

```swift
NavigationLink("Details") {
    DetailView()
        .clearNavigationBackground()  // Required for manual approach
}
```

### Gradient Not Visible

Verify configuration is set to `.standard` rather than `.minimal`:

```swift
PersistentBackgroundNavigation(palette: .ocean) {
    ContentView()
}
```

## Development History

This pattern was developed through iterative refinement to resolve NavigationStack background consistency issues.

Key development milestones:
- Resolved background consistency during color palette transitions
- Centralized background rendering and improved gradient visibility
- Removed LinearGradient tint overlays to improve navigation rendering

# SeaBearKit

[![Swift Version](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2017+%20|%20macOS%2014+-blue.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![SPM Compatible](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)](https://swift.org/package-manager)

A collection of SwiftUI layout patterns and UI components for iOS development.

## Core Feature: Persistent Background Navigation

The **PersistentBackgroundNavigation** component maintains consistent backgrounds across NavigationStack transitions.

This pattern was developed through extensive iteration to address SwiftUI's navigation background consistency issues.

## Features

### Navigation & Backgrounds
- **Automatic Navigation**: Background persistence without manual modifiers
- **Persistent Background System**: NavigationStack wrapper that maintains backgrounds during transitions
- **Flexible API**: Choose automatic convenience wrappers or manual control
- **Custom Backgrounds**: Use any SwiftUI view as a persistent background (images, videos, animations)

### Visuals
- **Gradient Backgrounds**: Configurable gradients with vignette effects (iOS 18+ Liquid Glass compatible)
- **Color Palettes**: Extensible palette system with nine built-in themes
- **Appearance Adaptive**: Automatic light/dark mode support
- **Material Integration**: Compatible with iOS 18+ material system

### View Modifiers
- **Conditional Modifiers**: Clean `.if()` syntax for conditional view transformations
- **Glass Shadows**: Unified `.glassShadow()` system for Liquid Glass UI with press states
- **Adaptive Corner Radius**: Proportional corner radius that scales across device sizes
- **Adaptive Inner Border**: Luminance-aware highlight borders for colored buttons

### Color Utilities
- **Luminance Analysis**: ITU-R BT.709 perceptual brightness calculations
- **Contrast Detection**: Automatic text color selection for backgrounds
- **Color Blending**: Linear interpolation with efficient pre-resolved components
- **Hex Conversion**: Full support for RGB, RRGGBB, and AARRGGBB formats

### Utilities
- **Haptic Feedback**: Low-latency haptics with pre-instantiated generators (iOS)
- **Shake Detection**: Simple `.onShake()` modifier (iOS)
- **Time Formatting**: Duration formatting as MM:SS

### Performance
- **Pure SwiftUI**: No external dependencies
- **Battery Optimized**: Static gradients with minimal impact
- **Pre-instantiated Haptics**: Avoid allocation delays during interactions

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

**Automatic (Recommended)** - No manual configuration required:
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

Both approaches work - choose what fits your style.

## Requirements

- iOS 17.0+ (iOS 18+ recommended for optimal experience)
- Swift 6.0+
- Xcode 15.0+

**Note**: While iOS 17 is supported, iOS 18+ provides the optimal experience using `.containerBackground(for: .navigation)`. iOS 17 uses a fallback approach that works well in most cases.

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/seabearDEV/SeaBearKit.git", from: "1.0.0")
]
```

Or in Xcode: File → Add Package Dependencies → Enter repository URL

## Navigation Approaches

SeaBearKit provides flexibility to match your coding style:

### Automatic (Recommended for most cases)

Use `PersistentNavigationLink` for automatic navigation:

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

Both approaches coexist - use what makes sense for each screen.

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

## Custom Backgrounds

Use any SwiftUI view as a persistent background:

```swift
PersistentBackgroundNavigation {
    // Your custom background
    Image("hero-image")
        .resizable()
        .aspectRatio(contentMode: .fill)
        .ignoresSafeArea()
} content: {
    ContentView()
}
```

Examples of custom backgrounds:
- **Images**: Hero images, patterns, textures
- **Videos**: Background video playback
- **Animated Gradients**: Time-based color transitions
- **Custom Views**: Any SwiftUI composition

The same persistent architecture applies - your custom background stays consistent across all navigation transitions.

## View Modifiers

SeaBearKit provides essential view modifiers for cleaner, more maintainable SwiftUI code.

### Conditional Modifiers

Apply transformations based on conditions without duplicating view code:

```swift
Text("Hello")
    .if(isHighlighted) { view in
        view.foregroundStyle(.red)
    }

// With both branches
Text("Status")
    .if(isActive,
        then: { $0.foregroundStyle(.green) },
        else: { $0.foregroundStyle(.gray) }
    )
```

### Glass Shadows

Unified shadow system optimized for Liquid Glass design with automatic press state handling:

```swift
// Basic shadow
Button("Action") { }
    .buttonStyle(.borderedProminent)
    .glassShadow()

// With press state
Text("Press Me")
    .padding()
    .background(.regularMaterial)
    .glassShadow(isPressed: isPressed, intensity: .regular)

// Different intensities
view.glassShadow(intensity: .subtle)     // Subtle elevation
view.glassShadow(intensity: .regular)    // Standard (default)
view.glassShadow(intensity: .prominent)  // High elevation
```

### Adaptive Corner Radius

Proportional corner radius system that scales consistently across device sizes:

```swift
// Using percentage (0% = square, 100% = circle)
RoundedRectangle(cornerRadius: 0)
    .fill(.blue)
    .frame(width: 100, height: 100)
    .adaptiveCornerRadius(40, size: CGSize(width: 100, height: 100))

// Using predefined styles
CornerRadiusStyle.square    // 0%   - Perfect squares
CornerRadiusStyle.slight    // 15%  - Subtle corners
CornerRadiusStyle.moderate  // 40%  - Balanced
CornerRadiusStyle.round     // 65%  - Prominent curves
CornerRadiusStyle.circle    // 100% - Perfect circles
```

### Adaptive Inner Border

Luminance-aware highlight border that creates depth on colored buttons:

```swift
RoundedRectangle(cornerRadius: 12)
    .fill(buttonColor)
    .adaptiveInnerBorder(color: buttonColor, cornerRadius: 12)
```

Light colors get a subtle dark top edge, dark colors get a subtle light top edge.

## Color Utilities

Comprehensive color manipulation for dynamic theming:

```swift
// Luminance and contrast
let textColor = backgroundColor.contrastingColor()  // Returns .black or .white
let isReadable = backgroundColor.isLight  // true if luminance > 0.6

// Color blending
let blended = Color.blend(from: .red, to: .blue, progress: 0.5)
let lighter = myColor.adjustedBrightness(0.2)
let darker = myColor.adjustedBrightness(-0.2)

// Hex conversion
let hex = myColor.toHex()           // "#ff5500"
let color = Color(hex: "#ff5500")   // Supports RGB, RRGGBB, AARRGGBB

// Efficient repeated blending (resolve once, blend many)
let resolved = startColor.resolvedRGBA
for progress in stride(from: 0, to: 1, by: 0.1) {
    let color = resolved.blend(to: endColor.resolvedRGBA, progress: progress)
}
```

## Haptic Feedback (iOS)

Low-latency haptic feedback with pre-instantiated generators:

```swift
// Impact feedback
HapticHelper.impact(.light)
HapticHelper.impact(.medium)
HapticHelper.impact(.rigid)
HapticHelper.impact(.heavy, intensity: 0.5)

// Notification feedback
HapticHelper.notification(.success)
HapticHelper.notification(.warning)
HapticHelper.notification(.error)

// Selection feedback (for pickers, segments)
HapticHelper.selection()

// Pre-warm for lower latency (optional)
HapticHelper.prepare(.medium)
```

## Shake Detection (iOS)

Simple shake gesture handling:

```swift
ContentView()
    .onShake {
        undoLastAction()
    }
```

## Time Formatting

Simple duration formatting:

```swift
45.formattedAsTime      // "0:45"
125.formattedAsTime     // "2:05"
3661.formattedAsTime    // "61:01"

let duration: TimeInterval = 125.7
duration.formattedAsTime  // "2:05"
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
git clone https://github.com/seabearDEV/SeaBearKit.git
cd SeaBearKit
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
    .package(path: "/path/to/SeaBearKit")
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

This library was developed to address common challenges encountered in iOS development.

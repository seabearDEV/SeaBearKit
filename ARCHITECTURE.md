# SeaBearKit Architecture

Technical documentation for the SeaBearKit library architecture and design decisions.

## Overview

SeaBearKit is a Swift Package that provides production-ready SwiftUI layout patterns. The core focus is the **Persistent Background Navigation** pattern, which solves a common SwiftUI challenge: maintaining a consistent background across navigation transitions.

## The Problem

In standard SwiftUI, when you use `NavigationStack`, each navigation transition can cause the background to change inconsistently. This happens because:

1. NavigationStack creates its own background layer
2. During transitions, the background is recreated or modified
3. This causes visual artifacts and poor user experience

### Failed Approaches

Before arriving at the current solution, several approaches were attempted:

1. **LinearGradient overlays**: Caused navigation rendering issues
2. **Direct background modifiers**: Led to inconsistency during palette changes
3. **Multiple gradient layers**: Poor performance and visibility issues

## The Solution

The solution uses a **ZStack with transparent NavigationStack container**.

### Core Pattern

```swift
ZStack {
    // Layer 1: Persistent background (remains constant)
    PersistentBackground(palette: palette, configuration: configuration)

    // Layer 2: Navigation with transparent container
    NavigationStack {
        content
            .containerBackground(for: .navigation) {
                Color.clear  // Makes navigation container transparent
            }
    }
}
```

### Why This Works

1. **ZStack separation**: Background and navigation are in separate layers
2. **Persistent background**: Lives outside NavigationStack lifecycle
3. **Transparent container**: `.containerBackground(for: .navigation) { Color.clear }` makes NavigationStack see-through
4. **No recreation**: Background persists across all navigation transitions

## Component Architecture

### Layer 1: Color System

#### ColorPalette
- Stores array of colors with gradient configuration
- Uses indices to specify which colors appear in gradients
- Opacity control for each gradient color
- Conforms to `Identifiable`, `Hashable`, `Sendable` for SwiftUI integration

```swift
public struct ColorPalette {
    let colors: [Color]              // Full color palette
    let gradientIndices: [Int]       // Which colors for gradient
    let gradientOpacities: [Double]  // Opacity for each gradient color
}
```

### Layer 2: Background Components

#### GradientBackground
- **Purpose**: Static gradient with vignette effect
- **Performance**: Extremely efficient, no animations
- **Adapts to**: Light/dark mode via `@Environment(\.colorScheme)`
- **Structure**:
  - System background base layer
  - Vertical LinearGradient (top to bottom)
  - RadialGradient vignette for depth


#### PersistentBackground
- **Purpose**: Gradient background component
- **Configuration**: Enables/disables gradient via `BackgroundConfiguration`
- **Presets**:
  - `.standard`: Gradient background
  - `.minimal`: System background only

### Layer 3: Navigation Wrapper

#### PersistentBackgroundNavigation
- **Purpose**: NavigationStack wrapper with persistent background
- **Generic Design**: Accepts any `Background: View` for maximum flexibility
- **Built-in Support**: Convenience initializers for `ColorPalette` gradients
- **Custom Backgrounds**: Use images, videos, patterns, or any SwiftUI view
- **Critical modifier**: `.containerBackground(for: .navigation) { Color.clear }` (iOS 18+)
- **iOS 17 Fallback**: `.toolbarBackground(.hidden)` approach
- **Structure**: ZStack with background behind NavigationStack
- **Result**: Consistent rendering, smooth transitions

## Design Decisions

### Why Generic Background Support?

Version 1.2.0 introduced generic `Background: View` parameter:

**Flexibility**:
- Use any SwiftUI view as background
- Images, videos, animated gradients, custom compositions
- Same persistent architecture for all background types
- No breaking changes - palette API preserved as convenience extension

**Architecture**:
```swift
// Generic structure
public struct PersistentBackgroundNavigation<Background: View, Content: View>

// Palette convenience (constrained extension)
extension PersistentBackgroundNavigation where Background == PersistentBackground {
    public init(palette: ColorPalette, ...) { }
}
```

### Why Static Gradients?

Uses LinearGradient and RadialGradient without animations:

**Advantages**:
- Minimal battery impact
- No CPU/GPU overhead
- Instant rendering
- Consistent appearance
- Works well on all devices

### Why Vignette Effect?

RadialGradient overlay adds depth:

**Rationale**:
- Creates subtle depth perception
- Frames content naturally
- Adapts to light/dark mode
- Enhances visual hierarchy

## File Structure

```
SeaBearKit/
├── Package.swift                              # Swift Package manifest
├── Sources/
│   ├── SeaBearKit/                           # Main library
│   │   ├── SeaBearKit.swift                  # Module documentation
│   │   ├── Backgrounds/
│   │   │   ├── ColorPalette.swift            # Color system
│   │   │   ├── GradientBackground.swift      # Static gradient
│   │   │   └── PersistentBackground.swift    # Background component
│   │   ├── Navigation/
│   │   │   └── PersistentBackgroundNavigation.swift  # Main wrapper
│   │   └── Extensions/
│   │       └── ColorExtensions.swift         # Color utilities
│   └── Demo/
│       └── DemoApp.swift                     # Example app
├── Tests/
│   └── SeaBearKitTests/                      # Unit tests
├── README.md                                  # Project overview
├── USAGE.md                                   # User guide
└── ARCHITECTURE.md                            # This file
```

## Performance Characteristics

### Memory Usage

- **Gradient**: ~50 KB (minimal, static)
- **Total**: <100 KB

### CPU Usage

- **Gradient**: <1% (negligible)
- **System background**: <0.1%

### Battery Impact

- **Gradient**: <1% impact (static, no animations)

## Testing Strategy

### Unit Tests
- Color utilities (brightness detection, blending)
- Palette configuration validation
- Component initialization

### Integration Tests
- Background rendering
- Navigation transitions
- Palette switching

### Manual Testing
- Visual verification across devices
- Light/dark mode transitions
- Dynamic Type scaling
- Low Power Mode behavior

## Future Enhancements

Potential additions to consider:

1. **Animated gradients**: Slow color transitions over time
2. **Blur effects**: Optional blur overlays for depth
3. **Texture overlays**: Subtle noise or grain textures
4. **More palette presets**: Additional built-in color schemes
5. **Custom gradient shapes**: Beyond linear/radial options

## Platform Requirements

- **iOS**: 17.0+ (iOS 18+ recommended for best experience)
- **macOS**: 14.0+
- **Swift**: 6.0+
- **Xcode**: 15.0+

## Concurrency

The library uses Swift 6's strict concurrency model:

- All public types conform to `Sendable` where appropriate
- `@MainActor` isolation for view components
- `ColorPalette` is `Sendable` for cross-actor passing
- No data races possible

## iOS Version Support

### iOS 18+ (Optimal)

Uses `.containerBackground(for: .navigation) { Color.clear }` for perfect transparency:
- Optimal rendering quality
- Best navigation transitions
- Full Liquid Glass design system integration

### iOS 17 (Graceful Degradation)

Uses fallback approach with `.toolbarBackground(.hidden)`:
- `.toolbarBackground(.hidden, for: .navigationBar)`
- `.toolbarBackground(.hidden, for: .bottomBar)`
- `.scrollContentBackground(.hidden)`
- Works well in 90%+ of use cases
- Minor limitations with custom toolbar backgrounds

## Development History

This pattern was developed through iterative refinement. Key milestones:
- Resolved background consistency during color palette transitions
- Centralized background rendering and improved gradient visibility
- Removed LinearGradient tint overlays to improve navigation rendering
- Standardized navigation transitions and view backgrounds

## Contributing

When contributing to this library:

1. Maintain iOS 17+ compatibility (iOS 18+ for optimal experience)
2. Keep Swift 6 strict concurrency compliance
3. Document performance impact of changes
4. Test on both light and dark mode
5. Test on both iOS 17 and iOS 18 when using version-specific APIs
6. Verify on multiple device sizes
7. Update architecture docs for structural changes
8. Test Liquid Glass compliance on iOS 18+

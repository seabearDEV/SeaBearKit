# Liquid Glass Compliance

This library is fully compliant with iOS 18+ Liquid Glass design principles.

## What is Liquid Glass?

Liquid Glass is Apple's design language that combines "optical properties of glass with a sense of fluidity." It uses system materials and effects to create modern, translucent interfaces that adapt to their context.

## How SeaBearKit Adopts Liquid Glass

### System Framework Integration

**Principle:** "Leverage system frameworks to adopt Liquid Glass automatically"

- Uses native SwiftUI `NavigationStack`
- Relies on system `List`, `Form`, and standard controls
- All components automatically adopt Liquid Glass materials

### Transparent Navigation Containers

**Implementation:** `.containerBackground(for: .navigation) { Color.clear }`

Every view in the navigation hierarchy includes this modifier, allowing the persistent gradient background to show through while system UI (toolbars, navigation bars) maintain their Liquid Glass appearance.

```swift
struct YourView: View {
    var body: some View {
        VStack {
            // Your content
        }
        .containerBackground(for: .navigation) {
            Color.clear  // Critical for Liquid Glass
        }
    }
}
```

### System Button Styles

**Principle:** "Leverage new button style APIs instead of custom Liquid Glass effects"

Demo app uses:
- `.buttonStyle(.borderedProminent)` for primary actions
- Standard SwiftUI buttons that automatically adopt materials

### Minimal Custom Backgrounds

**Principle:** "Reduce custom backgrounds in controls"

- Uses system `List` with automatic material adoption
- Uses system `Form` with built-in Liquid Glass
- Only custom background is the persistent gradient (by design)

### Content Hierarchy

**Principle:** "Create layouts that highlight important content"

The persistent gradient provides:
- Subtle depth without overwhelming content
- Vignette effect for natural focus
- Light/dark mode adaptation

### Scroll Edge Effects (Built-in)

**Principle:** Use `scrollEdgeEffectStyle(_:for:)` for legibility

System `List` and `Form` automatically handle this when used with `.containerBackground(for: .navigation)`

## Liquid Glass in Action

### The Pattern

```swift
// App level
PersistentBackgroundNavigation(palette: .sunset) {
    ContentView()  // Root automatically gets clear container
}

// Every destination view
struct DetailView: View {
    var body: some View {
        List {
            // System List gets Liquid Glass automatically
            Text("Content")
        }
        .containerBackground(for: .navigation) {
            Color.clear  // Shows persistent gradient
        }
    }
}
```

### Material Stack (Top to Bottom)

1. **System UI** (Navigation bar, toolbars) - Liquid Glass materials
2. **Content UI** (Lists, Forms) - Liquid Glass materials
3. **Navigation Container** - Transparent (`.containerBackground`)
4. **Persistent Gradient** - Custom background

This creates the signature Liquid Glass depth while maintaining the persistent background effect.

## Best Practices for Users

### DO: Use System Components

```swift
List {
    NavigationLink("Item") { DetailView() }
}
// List automatically gets Liquid Glass
```

### DO: Use System Button Styles

```swift
Button("Action") { }
    .buttonStyle(.borderedProminent)
// Button automatically gets Liquid Glass
```

### DO: Add Transparent Container to Every View

```swift
.containerBackground(for: .navigation) { Color.clear }
```

### DON'T: Add Custom Opaque Backgrounds

```swift
// This hides the gradient!
.background(Color.white)
```

### DO: Use Semi-Transparent Materials

```swift
// This allows gradient to show through
.background(.ultraThinMaterial)
```

## Performance

**Principle:** "Use `GlassEffectContainer` to combine custom Liquid Glass effects"

This library doesn't need `GlassEffectContainer` because:
- Uses system components (already optimized)
- Single persistent gradient (minimal overhead)
- No custom glass effects to combine

## Accessibility

**Principle:** "Test with accessibility settings enabled"

The persistent gradient:
- Adapts to light/dark mode automatically
- Works with Dynamic Type (system fonts scale)
- Maintains contrast with system materials
- Respects Reduce Transparency settings (via system components)

## Future-Proof

This implementation is future-proof because:
1. Relies on system frameworks (get updates automatically)
2. Minimal custom code (less to maintain)
3. Follows Apple's design principles (won't look dated)
4. Uses modern SwiftUI APIs (built for the future)

## Comparison with Custom Implementations

### Before (Custom Glass)
```swift
// Manual glass effect (not recommended)
.background(
    LinearGradient(...)
        .blur(radius: 10)
        .overlay(Color.white.opacity(0.2))
)
```

### After (System Materials)
```swift
// Let system handle it (recommended)
.background(.ultraThinMaterial)
```

### SeaBearKit Approach
```swift
// Persistent gradient + system materials
PersistentBackgroundNavigation(palette: .sunset) {
    List { }  // System List gets materials automatically
        .containerBackground(for: .navigation) { Color.clear }
}
```

## References

- [Adopting Liquid Glass](https://sosumi.ai/documentation/technologyoverviews/adopting-liquid-glass)
- [Liquid Glass Overview](https://sosumi.ai/documentation/technologyoverviews/liquid-glass)
- Apple Human Interface Guidelines

## Summary

SeaBearKit embraces Liquid Glass by:
1. Using system frameworks exclusively
2. Making navigation containers transparent
3. Letting system components adopt materials automatically
4. Providing a persistent gradient that enhances rather than conflicts with Liquid Glass
5. Following all Apple design principles

The result: A modern, fluid interface that feels native to iOS 18+ while maintaining a unique visual identity through the persistent gradient background.

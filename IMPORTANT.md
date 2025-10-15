# Implementation Requirements: PersistentBackgroundNavigation

## Required Modifier

All views in the navigation hierarchy must include:

```swift
.containerBackground(for: .navigation) {
    Color.clear
}
```

## Rationale

The `PersistentBackgroundNavigation` wrapper applies this modifier to the root view. Destination views must apply it independently to maintain background visibility during navigation.

## Example - Correct Implementation

```swift
// Root view (provided by wrapper)
PersistentBackgroundNavigation(palette: .sunset) {
    MenuView()  // containerBackground applied automatically
}

// Destination views MUST add it themselves
struct DetailView: View {
    var body: some View {
        VStack {
            Text("Detail Screen")
            // ... your content
        }
        .navigationTitle("Detail")
        .containerBackground(for: .navigation) {
            Color.clear
        }
    }
}

// Deeper destination views MUST add it too
struct DeepDetailView: View {
    var body: some View {
        VStack {
            Text("Deep Detail Screen")
            // ... your content
        }
        .navigationTitle("Deep Detail")
        .containerBackground(for: .navigation) {
            Color.clear
        }
    }
}
```

## Example - Incorrect Implementation

```swift
// Incorrect: Destination view missing containerBackground
struct DetailView: View {
    var body: some View {
        VStack {
            Text("Detail Screen")
        }
        .navigationTitle("Detail")
        // Missing .containerBackground - background will not persist
    }
}
```

## Implementation Checklist

Before deployment, verify:

- [ ] You've added `.containerBackground(for: .navigation) { Color.clear }` to **every** destination view
- [ ] You've added it to **every** nested destination view
- [ ] You've tested navigation to verify the background persists
- [ ] Content layers use semi-transparent materials (`.ultraThinMaterial`) rather than opaque backgrounds

## Common Implementation Error

```swift
// This only makes the ROOT transparent
PersistentBackgroundNavigation(palette: .sunset) {
    ContentView()
}

// Each navigation destination needs it too!
NavigationLink("Detail") {
    DetailView()  // Must have .containerBackground!
}
```

## Technical Limitation

SwiftUI's NavigationStack applies backgrounds on a per-screen basis. Each destination receives its own background layer, preventing automatic propagation of the modifier from the wrapper component.

## Development Origin

This requirement was identified through production testing, where all navigable views implement this modifier as a core pattern requirement.

## Alternative: View Extension

A convenience extension can simplify implementation:

```swift
extension View {
    func clearNavigationBackground() -> some View {
        self.containerBackground(for: .navigation) {
            Color.clear
        }
    }
}

// Usage
struct DetailView: View {
    var body: some View {
        VStack {
            Text("Detail")
        }
        .navigationTitle("Detail")
        .clearNavigationBackground()
    }
}
```

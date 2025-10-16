# Implementation Guide: PersistentBackgroundNavigation

## Two Approaches

SeaBearKit offers two approaches for persistent backgrounds:

### 1. Automatic (Recommended)

Use `PersistentNavigationLink` - background clearing happens automatically:

```swift
PersistentNavigationLink("Details") {
    DetailView()  // No modifier needed!
}
```

### 2. Manual (Advanced)

Use standard `NavigationLink` with manual `.clearNavigationBackground()`:

```swift
NavigationLink("Details") {
    DetailView()
        .clearNavigationBackground()  // Required
}
```

## Platform Considerations

### iOS 18+ (Optimal Experience)

Uses `.containerBackground(for: .navigation)` for complete transparency.

### iOS 17 (Fallback)

Uses toolbar background hiding as a fallback approach:
- `.toolbarBackground(.hidden, for: .navigationBar)`
- `.toolbarBackground(.hidden, for: .bottomBar)`
- `.scrollContentBackground(.hidden)`

**Known iOS 17 Limitations:**
- Custom toolbar backgrounds may conflict
- Some List/Form backgrounds may need explicit `.scrollContentBackground(.hidden)`
- Complex NavigationStack transitions may show brief flickers in edge cases
- Works well in 90%+ of use cases

## Example - Automatic Approach (Recommended)

```swift
PersistentBackgroundNavigation(palette: .sunset) {
    MenuView()
}

struct MenuView: View {
    var body: some View {
        VStack {
            // Automatic - no modifier needed on destination
            PersistentNavigationLink("Details") {
                DetailView()
            }

            PersistentNavigationLink("Settings") {
                SettingsView()
            }
        }
        .navigationTitle("Menu")
    }
}

struct DetailView: View {
    var body: some View {
        VStack {
            Text("Detail Screen")

            // Deep navigation also automatic
            PersistentNavigationLink("More") {
                DeepDetailView()
            }
        }
        .navigationTitle("Detail")
        // No .clearNavigationBackground() needed!
    }
}
```

## Example - Manual Approach

```swift
PersistentBackgroundNavigation(palette: .sunset) {
    MenuView()
}

struct MenuView: View {
    var body: some View {
        VStack {
            NavigationLink("Details") {
                DetailView()
            }
        }
        .navigationTitle("Menu")
    }
}

struct DetailView: View {
    var body: some View {
        VStack {
            Text("Detail Screen")
        }
        .navigationTitle("Detail")
        .clearNavigationBackground()  // Required for manual approach
    }
}

// Incorrect - Missing modifier
struct BrokenView: View {
    var body: some View {
        Text("Broken")
            .navigationTitle("Broken")
        // Missing .clearNavigationBackground() - background will disappear!
    }
}
```

## Implementation Checklist

### For Automatic Approach (Recommended)

- [ ] Use `PersistentNavigationLink` instead of `NavigationLink`
- [ ] Or use `.persistentNavigationDestination(for:)` for value-based navigation
- [ ] Test navigation on both iOS 17 and iOS 18 if supporting both
- [ ] Verify background persists through all navigation levels

### For Manual Approach

- [ ] Add `.clearNavigationBackground()` to **every** destination view
- [ ] Add it to **every** nested destination view
- [ ] Test navigation to verify the background persists
- [ ] On iOS 17, verify List/Form backgrounds are transparent

### General Best Practices

- [ ] Use semi-transparent materials (`.ultraThinMaterial`) for overlays
- [ ] Test in both light and dark mode
- [ ] Test on physical devices (especially iOS 17 if supported)
- [ ] Verify toolbar customizations work on iOS 17

## iOS 17 Troubleshooting

**Issue:** List/Form backgrounds are opaque on iOS 17

**Solution:** Add `.scrollContentBackground(.hidden)` explicitly:
```swift
List {
    // content
}
.scrollContentBackground(.hidden)  // iOS 17 may need this
.clearNavigationBackground()
```

**Issue:** Custom toolbar backgrounds conflict

**Solution:** Use iOS 18 check:
```swift
.toolbar {
    // toolbar content
}
.toolbarBackground(customColor, for: .navigationBar)  // May conflict on iOS 17
```

## Why Two Approaches?

**Automatic (`PersistentNavigationLink`):**
- ✅ Automatic - no manual configuration needed
- ✅ Scales to 100+ screens
- ✅ Junior-dev friendly

**Manual (`.clearNavigationBackground()`):**
- ✅ More control
- ✅ Add custom modifiers easily
- ✅ Works with existing codebases

Both approaches work together - mix and match as needed!

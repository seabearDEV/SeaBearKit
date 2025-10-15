# Demo Application

Methods for running the PersistentBackgroundNavigation demonstration:

## Option 1: Xcode Previews (Recommended)

Using Xcode's preview system:

1. Open the package in Xcode:
   ```bash
   open Package.swift
   ```

2. Navigate to `Sources/IOSLayouts/Navigation/PersistentBackgroundNavigation.swift`

3. Open the Canvas (⌥⌘↩ or Editor → Canvas)

4. You'll see two interactive previews:
   - "Navigation with Background" - Shows the persistent background pattern with navigation
   - "Minimal Background" - Shows minimal mode with system background only

5. Click the "Live Preview" button to interact with the navigation

## Option 2: New iOS Application

Creating a standalone application with full demo features:

1. **Create a new iOS App in Xcode:**
   - File → New → Project
   - Choose "iOS" → "App"
   - Product Name: "IOSLayoutsDemo"
   - Interface: SwiftUI
   - Language: Swift

2. **Add the IOSLayouts package:**
   - File → Add Package Dependencies
   - Enter local path: `/Users/kh/Projects/github.com/seabearDEV/ios-layouts`
   - Add to project

3. **Replace the app file content** with the demo code from:
   `Sources/Demo/DemoApp.swift`

4. **Run on simulator or device** (⌘R)

## Option 3: Swift Playgrounds

Swift Playground implementation:

```swift
import SwiftUI
import IOSLayouts
import PlaygroundSupport

struct ContentView: View {
    var body: some View {
        PersistentBackgroundNavigation(palette: .sunset) {
            List {
                NavigationLink("Screen 1") {
                    DetailView(title: "Screen 1")
                }
                NavigationLink("Screen 2") {
                    DetailView(title: "Screen 2")
                }
                NavigationLink("Screen 3") {
                    DetailView(title: "Screen 3")
                }
            }
            .navigationTitle("Demo")
        }
    }
}

struct DetailView: View {
    let title: String

    var body: some View {
        VStack {
            Text(title)
                .font(.largeTitle)
            Text("Notice the persistent background!")
                .padding()

            NavigationLink("Go Deeper") {
                DetailView(title: "\(title) > Detail")
            }
        }
        .navigationTitle(title)
        .containerBackground(for: .navigation) {
            Color.clear
        }
    }
}

PlaygroundPage.current.setLiveView(ContentView())
```

## Demonstration Features

Key behaviors to observe:

1. **Flicker Elimination**: Background gradient maintains consistency during screen transitions
2. **Transition Quality**: Navigation animations execute without visual artifacts
3. **Palette Transitions**: Color palette changes animate smoothly
4. **Configuration Modes**: Standard (gradient) and Minimal (system background) options available
5. **Material Integration**: System Lists and Forms adopt Liquid Glass materials over the gradient layer

## Comparison with Standard Implementation

Standard NavigationStack background approach:

```swift
// Standard approach (flickers during navigation)
ZStack {
    LinearGradient(...)
    NavigationStack {
        ContentView()
    }
}
```

IOSLayouts approach:

```swift
// Flicker-free implementation
PersistentBackgroundNavigation(palette: .sunset) {
    ContentView()
}
```

The architectural difference eliminates flicker during navigation transitions.

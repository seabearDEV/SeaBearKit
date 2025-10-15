//
//  DemoApp.swift
//  IOSLayoutsDemo
//
//  Demo application showcasing the PersistentBackgroundNavigation pattern.
//

import SwiftUI
import IOSLayouts

@main
struct DemoApp: App {
    @State private var selectedPalette: ColorPalette = .sunset
    @State private var configuration: BackgroundConfiguration = .standard

    var body: some Scene {
        WindowGroup {
            PersistentBackgroundNavigation(
                palette: selectedPalette,
                configuration: configuration
            ) {
                MainMenuView(
                    selectedPalette: $selectedPalette,
                    configuration: $configuration
                )
            }
        }
    }
}

// MARK: - Main Menu

struct MainMenuView: View {
    @Binding var selectedPalette: ColorPalette
    @Binding var configuration: BackgroundConfiguration

    var body: some View {
        List {
            // Liquid Glass: System List automatically adopts materials
            Section("Examples") {
                NavigationLink("Simple Navigation") {
                    SimpleNavigationDemo()
                }

                NavigationLink("Deep Navigation") {
                    DeepNavigationDemo()
                }

                NavigationLink("List with Details") {
                    ListDemo()
                }

                NavigationLink("Form Example") {
                    FormDemo()
                }
            }

            Section("Palette Selection") {
                ForEach(ColorPalette.samplePalettes) { palette in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedPalette = palette
                        }
                    }) {
                        HStack {
                            Text(palette.name)
                            Spacer()
                            if selectedPalette.id == palette.id {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                }
            }

            Section("Background Mode") {
                Button("Standard (Gradient Background)") {
                    configuration = .standard
                }
                .foregroundStyle(configuration.showGradient ? .blue : .primary)

                Button("Minimal (System Background)") {
                    configuration = .minimal
                }
                .foregroundStyle(!configuration.showGradient ? .blue : .primary)
            }

            Section("About") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("IOSLayouts Demo")
                        .font(.headline)
                    Text("Showcasing the PersistentBackgroundNavigation pattern with gradient backgrounds. Navigate between screens to see how the background persists without flickering.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("IOSLayouts Demo")
        .clearNavigationBackground()
    }
}

// MARK: - Simple Navigation Demo

struct SimpleNavigationDemo: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)

            Text("Simple Navigation")
                .font(.title)
                .fontWeight(.bold)

            Text("Notice how the background remains consistent and doesn't flicker during the navigation transition.")
                .multilineTextAlignment(.center)
                .padding()

            NavigationLink("Next Screen") {
                DetailScreen(
                    title: "Level 2",
                    icon: "star.fill",
                    color: .yellow
                )
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Simple Navigation")
        .clearNavigationBackground()
    }
}

// MARK: - Deep Navigation Demo

struct DeepNavigationDemo: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "arrow.down.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            Text("Deep Navigation")
                .font(.title)
                .fontWeight(.bold)

            Text("Navigate through multiple levels and observe how the persistent background maintains visual continuity.")
                .multilineTextAlignment(.center)
                .padding()

            NavigationLink("Go Deeper (Level 1)") {
                DeepLevelView(level: 1)
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Deep Navigation")
        .clearNavigationBackground()
    }
}

struct DeepLevelView: View {
    let level: Int

    var body: some View {
        VStack(spacing: 24) {
            Text("Level \(level)")
                .font(.largeTitle)
                .fontWeight(.bold)

            if level < 5 {
                NavigationLink("Go Deeper (Level \(level + 1))") {
                    DeepLevelView(level: level + 1)
                }
                .buttonStyle(.borderedProminent)
            } else {
                Image(systemName: "flag.checkered")
                    .font(.system(size: 60))
                    .foregroundStyle(.green)
                Text("You've reached the end!")
                    .font(.title2)
            }
        }
        .navigationTitle("Level \(level)")
        .clearNavigationBackground()
    }
}

// MARK: - List Demo

struct ListDemo: View {
    let items = [
        ("Item 1", "star.fill", Color.yellow),
        ("Item 2", "heart.fill", Color.red),
        ("Item 3", "leaf.fill", Color.green),
        ("Item 4", "cloud.fill", Color.blue),
        ("Item 5", "flame.fill", Color.orange),
    ]

    var body: some View {
        List {
            ForEach(items.indices, id: \.self) { index in
                NavigationLink {
                    DetailScreen(
                        title: items[index].0,
                        icon: items[index].1,
                        color: items[index].2
                    )
                } label: {
                    Label(items[index].0, systemImage: items[index].1)
                }
            }
        }
        .navigationTitle("List Example")
        .clearNavigationBackground()
    }
}

// MARK: - Form Demo

struct FormDemo: View {
    @State private var name = ""
    @State private var isEnabled = true
    @State private var selectedOption = 0

    var body: some View {
        Form {
            Section("User Info") {
                TextField("Name", text: $name)
                Toggle("Enabled", isOn: $isEnabled)
            }

            Section("Options") {
                Picker("Choose", selection: $selectedOption) {
                    Text("Option 1").tag(0)
                    Text("Option 2").tag(1)
                    Text("Option 3").tag(2)
                }

                NavigationLink("Advanced Settings") {
                    DetailScreen(
                        title: "Advanced",
                        icon: "gearshape.fill",
                        color: .gray
                    )
                }
            }
        }
        .navigationTitle("Form Example")
        .clearNavigationBackground()
    }
}

// MARK: - Detail Screen

struct DetailScreen: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundStyle(color)

            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("The persistent background pattern ensures smooth visual transitions throughout your navigation hierarchy.")
                .multilineTextAlignment(.center)
                .padding()

            Divider()
                .padding()

            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(
                    icon: "checkmark.circle.fill",
                    text: "No background flickering"
                )
                FeatureRow(
                    icon: "checkmark.circle.fill",
                    text: "Smooth transitions"
                )
                FeatureRow(
                    icon: "checkmark.circle.fill",
                    text: "Consistent visual identity"
                )
                FeatureRow(
                    icon: "checkmark.circle.fill",
                    text: "Elegant gradient backgrounds"
                )
            }
            .padding()
        }
        .navigationTitle(title)
        .clearNavigationBackground()
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.green)
            Text(text)
        }
    }
}

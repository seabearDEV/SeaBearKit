//
//  DemoApp.swift
//  SeaBearKitDemo
//
//  Demo application showcasing the PersistentBackgroundNavigation pattern.
//

import SwiftUI
import SeaBearKit

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
            Section("Automatic Navigation (Recommended)") {
                PersistentNavigationLink("Simple Navigation") {
                    SimpleNavigationDemo()
                }

                PersistentNavigationLink("Deep Navigation (5 levels)") {
                    DeepNavigationDemo()
                }

                PersistentNavigationLink("List with Details") {
                    ListDemo()
                }
            }

            Section("Manual Navigation (Advanced)") {
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
                    Text("Showcasing two navigation approaches: Automatic (PersistentNavigationLink) for zero friction, and Manual (.clearNavigationBackground()) for advanced control. Both maintain perfect background persistence.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("IOSLayouts Demo")
        .navigationBarTitleDisplayMode(.large)
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

            Text("Automatic Navigation")
                .font(.title)
                .fontWeight(.bold)

            Text("Uses PersistentNavigationLink for zero-friction background persistence. No manual modifiers needed!")
                .multilineTextAlignment(.center)
                .padding()

            PersistentNavigationLink("Next Screen") {
                DetailScreen(
                    title: "Detail",
                    icon: "star.fill",
                    color: .yellow,
                    depth: 2
                )
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Simple Navigation")
        .navigationBarTitleDisplayMode(.inline)
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

            Text("Navigate through 5 levels using PersistentNavigationLink. Background stays consistent automatically.")
                .multilineTextAlignment(.center)
                .padding()

            PersistentNavigationLink("Start Journey") {
                DeepLevelView(level: 1)
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Deep Navigation")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DeepLevelView: View {
    let level: Int

    var body: some View {
        VStack(spacing: 24) {
            // Show depth indicator as badge
            HStack(spacing: 8) {
                ForEach(1...level, id: \.self) { _ in
                    Circle()
                        .fill(.blue)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 8)

            Text("Level \(level)")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Depth: \(level) deep")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom)

            if level < 5 {
                PersistentNavigationLink("Continue to Level \(level + 1)") {
                    DeepLevelView(level: level + 1)
                }
                .buttonStyle(.borderedProminent)
            } else {
                Image(systemName: "flag.checkered")
                    .font(.system(size: 60))
                    .foregroundStyle(.green)
                Text("Maximum Depth Reached")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Background automatic at all 5 levels!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Level \(level)")
        .navigationBarTitleDisplayMode(.inline)
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
                PersistentNavigationLink {
                    DetailScreen(
                        title: items[index].0,
                        icon: items[index].1,
                        color: items[index].2,
                        depth: 2
                    )
                } label: {
                    Label(items[index].0, systemImage: items[index].1)
                }
            }
        }
        .navigationTitle("List Example")
        .navigationBarTitleDisplayMode(.inline)
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
                        color: .gray,
                        depth: 2
                    )
                }
            }
        }
        .navigationTitle("Form Example")
        .navigationBarTitleDisplayMode(.inline)
        .clearNavigationBackground()
    }
}

// MARK: - Detail Screen

struct DetailScreen: View {
    let title: String
    let icon: String
    let color: Color
    let depth: Int

    var body: some View {
        VStack(spacing: 24) {
            // Depth indicator
            HStack(spacing: 8) {
                ForEach(1...depth, id: \.self) { _ in
                    Circle()
                        .fill(color.opacity(0.6))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 4)

            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundStyle(color)

            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Navigation depth: \(depth)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("The persistent background pattern ensures smooth visual transitions throughout your navigation hierarchy.")
                .multilineTextAlignment(.center)
                .padding()

            Divider()
                .padding()

            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(
                    icon: "checkmark.circle.fill",
                    text: "Consistent background rendering"
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
                    text: "Gradient persists at depth \(depth)"
                )
            }
            .padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
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

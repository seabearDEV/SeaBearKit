//
//  PersistentBackgroundNavigation.swift
//  IOSLayouts
//
//  NavigationStack wrapper that maintains a persistent background across all navigation transitions.
//  This pattern was developed through iterative refinement to ensure background consistency.
//
//  CRITICAL: Uses .containerBackground(for: .navigation) { Color.clear } to ensure
//  consistent navigation transition rendering and background persistence.
//

import SwiftUI

#if canImport(UIKit)

/// A NavigationStack wrapper that maintains a persistent background during navigation transitions.
///
/// This component solves a common SwiftUI challenge: maintaining a consistent background
/// across navigation transitions.
///
/// ## Usage
///
/// ```swift
/// PersistentBackgroundNavigation(
///     palette: .sunset,
///     configuration: .full
/// ) {
///     YourRootView()
/// }
/// ```
///
/// ## The Pattern
///
/// The magic is in the structure:
/// 1. ZStack contains both background and NavigationStack
/// 2. Background is positioned behind the entire NavigationStack
/// 3. **EVERY view in the navigation hierarchy** must use `.containerBackground(for: .navigation) { Color.clear }`
/// 4. This makes the navigation container transparent, revealing the persistent background
///
/// **IMPORTANT**: Each destination view must also add `.containerBackground(for: .navigation) { Color.clear }`,
/// otherwise the background will disappear when navigating to that view.
///
/// Without this pattern, NavigationStack creates its own background that changes during
/// transitions, causing visual inconsistencies.
///
public struct PersistentBackgroundNavigation<Content: View>: View {
    let palette: ColorPalette
    let configuration: BackgroundConfiguration
    let content: Content

    /// Creates a navigation view with a persistent gradient background.
    /// - Parameters:
    ///   - palette: The color palette for the background
    ///   - configuration: Background configuration options (default: .standard)
    ///   - content: The root view of your navigation hierarchy
    public init(
        palette: ColorPalette,
        configuration: BackgroundConfiguration = .standard,
        @ViewBuilder content: () -> Content
    ) {
        self.palette = palette
        self.configuration = configuration
        self.content = content()
    }

    public var body: some View {
        ZStack {
            // Layer 1: Persistent background (sits behind everything)
            PersistentBackground(palette: palette, configuration: configuration)

            // Layer 2: NavigationStack with transparent container
            NavigationStack {
                content
                    // CRITICAL: This ensures consistent rendering
                    // Makes the navigation container background transparent
                    // so the persistent background remains visible
                    .containerBackground(for: .navigation) {
                        Color.clear
                    }
            }
        }
    }
}

// MARK: - Convenience Initializers

extension PersistentBackgroundNavigation {
    /// Creates a navigation view with minimal background (system background only).
    public static func minimal(
        palette: ColorPalette,
        @ViewBuilder content: () -> Content
    ) -> PersistentBackgroundNavigation {
        PersistentBackgroundNavigation(
            palette: palette,
            configuration: .minimal,
            content: content
        )
    }
}

// MARK: - Preview

#Preview("Navigation with Background") {
    PersistentBackgroundNavigation(palette: .sunset) {
        VStack(spacing: 24) {
            Text("Persistent Background Demo")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)

            Text("Notice the gradient background behind the navigation")
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(spacing: 16) {
                GlassNavigationButton(icon: "1.circle.fill", title: "Screen 1") {
                    DetailView(screenNumber: 1, color: .red, depth: 1)
                }

                GlassNavigationButton(icon: "2.circle.fill", title: "Screen 2") {
                    DetailView(screenNumber: 2, color: .blue, depth: 1)
                }

                GlassNavigationButton(icon: "3.circle.fill", title: "Screen 3") {
                    DetailView(screenNumber: 3, color: .green, depth: 1)
                }
            }
            .padding()

            Spacer()
        }
        .navigationTitle("Demo")
    }
}

#Preview("Minimal Background") {
    PersistentBackgroundNavigation.minimal(palette: .ocean) {
        VStack(spacing: 24) {
            Text("Minimal Background Demo")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)

            Text("System background only (no gradient)")
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(spacing: 16) {
                GlassNavigationButton(icon: "1.circle.fill", title: "Screen 1") {
                    DetailView(title: "Screen 1", color: .red)
                }
            }
            .padding()

            Spacer()
        }
        .navigationTitle("Minimal Demo")
    }
}

// MARK: - Preview Helper

private struct DetailView: View {
    let screenNumber: Int
    let color: Color
    let depth: Int

    // For backward compatibility with minimal preview
    init(title: String, color: Color, depth: Int = 1) {
        // Extract screen number from title like "Screen 1" or default to 1
        if let number = Int(title.replacingOccurrences(of: "Screen ", with: "")) {
            self.screenNumber = number
        } else {
            self.screenNumber = 1
        }
        self.color = color
        self.depth = depth
    }

    init(screenNumber: Int, color: Color, depth: Int = 1) {
        self.screenNumber = screenNumber
        self.color = color
        self.depth = depth
    }

    var title: String {
        "Screen \(screenNumber) Level \(depth)"
    }

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

            RoundedRectangle(cornerRadius: 24)
                .fill(color.opacity(0.3))
                .frame(width: 200, height: 200)
                .overlay(
                    VStack {
                        Image(systemName: "star.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(color)
                        Text(title)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                )

            Text("Depth: \(depth)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("The gradient background persists during navigation transitions.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if depth < 4 {
                GlassButton(
                    label: "Go to Level \(depth + 1)",
                    icon: "arrow.right",
                    iconPosition: .trailing
                ) {
                    DetailView(
                        screenNumber: screenNumber,
                        color: color.opacity(0.8),
                        depth: depth + 1
                    )
                }
                .frame(maxWidth: 200)
            } else {
                Text("Maximum depth reached")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.top, 40)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .containerBackground(for: .navigation) {
            Color.clear
        }
    }
}

// MARK: - Glass Navigation Button

/// Icon position for glass buttons
private enum IconPosition {
    case leading, trailing
}

/// A NavigationLink styled with Liquid Glass material that handles pressed states properly
private struct GlassNavigationButton<Destination: View>: View {
    let icon: String
    let title: String
    let destination: Destination

    @State private var isPressed = false

    init(icon: String, title: String, @ViewBuilder destination: () -> Destination) {
        self.icon = icon
        self.title = title
        self.destination = destination()
    }

    var body: some View {
        NavigationLink {
            destination
        } label: {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.blue)
                Text(title)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.regularMaterial)

                    // Add subtle overlay on press for better visibility
                    if isPressed {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white.opacity(0.15))
                    }
                }
            )
            .shadow(color: .black.opacity(isPressed ? 0.05 : 0.15), radius: isPressed ? 4 : 10, y: isPressed ? 2 : 5)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
        }
        .buttonStyle(.plain) // Prevents default NavigationLink opacity change
        .foregroundStyle(.primary)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

/// A centered NavigationLink button styled with Liquid Glass material
private struct GlassButton<Destination: View>: View {
    let label: String
    let icon: String
    let iconPosition: IconPosition
    let destination: Destination

    @State private var isPressed = false

    init(
        label: String,
        icon: String,
        iconPosition: IconPosition = .leading,
        @ViewBuilder destination: () -> Destination
    ) {
        self.label = label
        self.icon = icon
        self.iconPosition = iconPosition
        self.destination = destination()
    }

    var body: some View {
        NavigationLink {
            destination
        } label: {
            HStack(spacing: 8) {
                if iconPosition == .leading {
                    Image(systemName: icon)
                }
                Text(label)
                    .fontWeight(.semibold)
                if iconPosition == .trailing {
                    Image(systemName: icon)
                }
            }
            .padding()
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.regularMaterial)

                    // Add subtle overlay on press for better visibility
                    if isPressed {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white.opacity(0.15))
                    }
                }
            )
            .shadow(color: .black.opacity(isPressed ? 0.05 : 0.15), radius: isPressed ? 4 : 10, y: isPressed ? 2 : 5)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

#endif // canImport(UIKit)

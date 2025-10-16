//
//  PersistentBackgroundNavigation.swift
//  IOSLayouts
//
//  NavigationStack wrapper with persistent background across navigation transitions.
//  Child views call .clearNavigationBackground() to reveal the background.
//

import SwiftUI

#if canImport(UIKit)

/// NavigationStack wrapper that maintains a persistent background across all navigation transitions.
///
/// ## Usage
///
/// ```swift
/// PersistentBackgroundNavigation(palette: .sunset) {
///     ContentView()
/// }
/// ```
///
/// Add `.clearNavigationBackground()` to each destination view:
///
/// ```swift
/// struct DetailView: View {
///     var body: some View {
///         Text("Detail View")
///             .navigationTitle("Details")
///             .clearNavigationBackground()
///     }
/// }
/// ```
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
                if #available(iOS 18.0, *) {
                    // iOS 18: Use containerBackground for perfect transparency
                    content
                        .containerBackground(for: .navigation) {
                            Color.clear
                        }
                } else {
                    // iOS 17: Root content doesn't need special handling
                    // Child views will use .clearNavigationBackground()
                    content
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
                    DetailView(screenNumber: 1, color: .red)
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
        .clearNavigationBackground()
    }
}

// MARK: - Glass Navigation Button

/// Shared glass material styling for NavigationLinks
private struct GlassNavigationLinkStyle: ViewModifier {
    @Binding var isPressed: Bool

    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white.opacity(isPressed ? 0.15 : 0))
                    )
            )
            .shadow(color: .black.opacity(isPressed ? 0.05 : 0.15), radius: isPressed ? 4 : 10, y: isPressed ? 2 : 5)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
    }
}

/// A NavigationLink styled with glass material
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
        NavigationLink(destination: destination) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.blue)
                Text(title)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .modifier(GlassNavigationLinkStyle(isPressed: $isPressed))
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

/// A centered NavigationLink button with glass material
private struct GlassButton<Destination: View>: View {
    let label: String
    let icon: String
    let iconTrailing: Bool
    let destination: Destination
    @State private var isPressed = false

    init(label: String, icon: String, iconPosition: IconPosition = .leading, @ViewBuilder destination: () -> Destination) {
        self.label = label
        self.icon = icon
        self.iconTrailing = iconPosition == .trailing
        self.destination = destination()
    }

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 8) {
                if !iconTrailing { Image(systemName: icon) }
                Text(label).fontWeight(.semibold)
                if iconTrailing { Image(systemName: icon) }
            }
            .modifier(GlassNavigationLinkStyle(isPressed: $isPressed))
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

/// Icon position for glass buttons
private enum IconPosition {
    case leading, trailing
}

#endif // canImport(UIKit)

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
/// ## Usage with Color Palette
///
/// ```swift
/// PersistentBackgroundNavigation(palette: .sunset) {
///     ContentView()
/// }
/// ```
///
/// ## Usage with Custom Background
///
/// ```swift
/// PersistentBackgroundNavigation {
///     Image("hero-background")
///         .resizable()
///         .ignoresSafeArea()
/// } content: {
///     ContentView()
/// }
/// ```
///
/// Add `.clearNavigationBackground()` to each destination view or use `PersistentNavigationLink`.
///
public struct PersistentBackgroundNavigation<Background: View, Content: View>: View {
    let background: Background
    let content: Content

    /// Creates a navigation view with a custom background.
    /// - Parameters:
    ///   - background: Custom view to use as the persistent background
    ///   - content: The root view of your navigation hierarchy
    public init(
        @ViewBuilder background: () -> Background,
        @ViewBuilder content: () -> Content
    ) {
        self.background = background()
        self.content = content()
    }

    public var body: some View {
        ZStack {
            // Layer 1: Persistent background (sits behind everything)
            background

            // Layer 2: NavigationStack with transparent container
            NavigationStack {
                if #available(iOS 18.0, *) {
                    // iOS 18: Use containerBackground for complete transparency
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

// MARK: - Convenience Initializers for Color Palettes

extension PersistentBackgroundNavigation where Background == PersistentBackground {
    /// Creates a navigation view with a persistent gradient background from a color palette.
    /// - Parameters:
    ///   - palette: The color palette for the background
    ///   - configuration: Background configuration options (default: .standard)
    ///   - content: The root view of your navigation hierarchy
    public init(
        palette: ColorPalette,
        configuration: BackgroundConfiguration = .standard,
        @ViewBuilder content: () -> Content
    ) {
        self.background = PersistentBackground(palette: palette, configuration: configuration)
        self.content = content()
    }

    /// Creates a navigation view with minimal background (system background only).
    /// - Parameters:
    ///   - palette: The color palette (used for adaptive color selection)
    ///   - content: The root view of your navigation hierarchy
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

#Preview("Gradient Background") {
    PersistentBackgroundNavigation(palette: .sunset) {
        VStack(spacing: 24) {
            Text("Gradient Background")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)

            Text("Built-in color palette gradient")
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
        .navigationTitle("Gradient Demo")
    }
}

#Preview("Custom Background") {
    PersistentBackgroundNavigation {
        // Custom pattern background
        ZStack {
            Color.indigo

            GeometryReader { geometry in
                Path { path in
                    let size = geometry.size
                    let gridSize: CGFloat = 40

                    // Vertical lines
                    for x in stride(from: 0, through: size.width, by: gridSize) {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                    }

                    // Horizontal lines
                    for y in stride(from: 0, through: size.height, by: gridSize) {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    }
                }
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
            }
        }
        .ignoresSafeArea()
    } content: {
        VStack(spacing: 24) {
            Text("Custom Background")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)

            Text("Any SwiftUI view as background")
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
        .navigationTitle("Custom Demo")
    }
}

#Preview("Minimal Background") {
    PersistentBackgroundNavigation.minimal(palette: .ocean) {
        VStack(spacing: 24) {
            Text("Minimal Background")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)

            Text("System background only")
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

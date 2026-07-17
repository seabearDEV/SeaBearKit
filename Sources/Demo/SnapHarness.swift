//
//  SnapHarness.swift
//  SeaBearKitDemo
//
//  Screenshot harness: reads SEABEAR_SNAP from the launch environment and
//  poses the app on the requested slide. Inert when the variable is absent.
//  Driven by tools/screenshots/shoot.sh — see commands.screenshots.
//

import SwiftUI
import SeaBearKit

/// The slide requested via SEABEAR_SNAP, if any.
enum Snapshot: String {
    case menu       // main menu, sunset (hero)
    case depth      // Level 5 of the deep-navigation demo
    case list       // list demo, ocean
    case form       // form demo, forest
    case palettes   // gallery of all sample palettes
    case custom     // custom grid-pattern background
    case dark       // main menu, midnight (script sets dark appearance)

    static let current = ProcessInfo.processInfo
        .environment["SEABEAR_SNAP"]
        .flatMap(Snapshot.init(rawValue:))

    var palette: ColorPalette {
        switch self {
        case .menu, .depth, .custom: .sunset
        case .list: .ocean
        case .form: .forest
        case .palettes: .lavender
        case .dark: .midnight
        }
    }

    /// Whether this slide is a pushed screen rather than the root menu.
    var pushes: Bool {
        switch self {
        case .menu, .custom, .dark: false
        case .depth, .list, .form, .palettes: true
        }
    }

    @MainActor @ViewBuilder
    var destination: some View {
        switch self {
        case .depth: DeepLevelView(level: 5)
        case .list: ListDemo()
        case .form: FormDemo()
        case .palettes: PaletteGalleryView()
        case .menu, .custom, .dark: EmptyView()
        }
    }
}

extension View {
    /// Pushes the requested slide's screen shortly after launch.
    func snapAutoPush() -> some View {
        modifier(SnapAutoPushModifier())
    }
}

private struct SnapAutoPushModifier: ViewModifier {
    @State private var isPushed = false

    func body(content: Content) -> some View {
        if let snap = Snapshot.current, snap.pushes {
            content
                .persistentNavigationDestination(isPresented: $isPushed) {
                    snap.destination
                }
                .task {
                    try? await Task.sleep(for: .seconds(1))
                    isPushed = true
                }
        } else {
            content
        }
    }
}

// MARK: - Palette Gallery

/// Snap-only screen showing every sample palette as a gradient swatch card.
struct PaletteGalleryView: View {
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(ColorPalette.samplePalettes) { palette in
                    PaletteCard(palette: palette)
                }
            }
            .padding()
        }
        .navigationTitle("Built-in Palettes")
        .navigationBarTitleDisplayMode(.inline)
        .clearNavigationBackground()
    }
}

private struct PaletteCard: View {
    let palette: ColorPalette

    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: palette.gradientIndices.map { palette.colors[$0] },
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 105)

            Text(palette.name)
                .font(.subheadline.weight(.medium))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .padding(.horizontal, 6)
                .background(.regularMaterial)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .glassShadow()
    }
}

// MARK: - Custom Background

/// Snap-only background for the "bring any SwiftUI view" slide — the indigo
/// grid pattern from the PersistentBackgroundNavigation previews.
struct GridPatternBackground: View {
    var body: some View {
        ZStack {
            Color.indigo

            GeometryReader { geometry in
                Path { path in
                    let size = geometry.size
                    let gridSize: CGFloat = 40

                    for x in stride(from: 0, through: size.width, by: gridSize) {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                    }

                    for y in stride(from: 0, through: size.height, by: gridSize) {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    }
                }
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
            }
        }
        .ignoresSafeArea()
    }
}

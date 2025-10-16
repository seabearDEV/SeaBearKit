//
//  AutomaticPersistentNavigation.swift
//  IOSLayouts
//
//  Automatic navigation wrappers that eliminate manual modifier requirements.
//  These components automatically apply .clearNavigationBackground() to destinations.
//

import SwiftUI

#if canImport(UIKit)

// MARK: - Automatic NavigationLink

/// A NavigationLink that automatically applies persistent background transparency.
///
/// This is a drop-in replacement for `NavigationLink` that automatically applies
/// `.clearNavigationBackground()` to the destination view, eliminating the need
/// for manual modifier application.
///
/// ## Usage
///
/// ```swift
/// PersistentNavigationLink("Details") {
///     DetailView()  // No .clearNavigationBackground() needed!
/// }
/// ```
///
/// ## Variants
///
/// ```swift
/// // With custom label
/// PersistentNavigationLink {
///     DetailView()
/// } label: {
///     Text("View Details")
/// }
///
/// // Value-based navigation (use .persistentNavigationDestination instead)
/// ```
///
@available(iOS 17.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct PersistentNavigationLink<Label: View, Destination: View>: View {
    private let destination: Destination
    private let label: Label

    /// Creates a navigation link with a text label.
    public init(_ titleKey: LocalizedStringKey, @ViewBuilder destination: () -> Destination) where Label == Text {
        self.destination = destination()
        self.label = Text(titleKey)
    }

    /// Creates a navigation link with a string label.
    public init<S: StringProtocol>(_ title: S, @ViewBuilder destination: () -> Destination) where Label == Text {
        self.destination = destination()
        self.label = Text(title)
    }

    /// Creates a navigation link with a custom label.
    public init(@ViewBuilder destination: () -> Destination, @ViewBuilder label: () -> Label) {
        self.destination = destination()
        self.label = label()
    }

    public var body: some View {
        NavigationLink {
            destination
                .clearNavigationBackground()
        } label: {
            label
        }
    }
}

// MARK: - Automatic Navigation Destination Modifiers

extension View {
    /// Registers a destination view for value-based navigation with automatic background clearing.
    ///
    /// This is a drop-in replacement for `.navigationDestination(for:)` that automatically
    /// applies `.clearNavigationBackground()` to destination views.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// NavigationStack {
    ///     ContentView()
    /// }
    /// .persistentNavigationDestination(for: Item.self) { item in
    ///     ItemDetailView(item: item)  // No .clearNavigationBackground() needed!
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - data: The type of data that this destination matches.
    ///   - destination: A view builder that creates the destination view.
    ///
    @available(iOS 17.0, *)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public func persistentNavigationDestination<D: Hashable, C: View>(
        for data: D.Type,
        @ViewBuilder destination: @escaping (D) -> C
    ) -> some View {
        self.navigationDestination(for: data) { value in
            destination(value)
                .clearNavigationBackground()
        }
    }

    /// Registers a destination view for optional value-based navigation with automatic background clearing.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// NavigationStack {
    ///     ContentView()
    /// }
    /// .persistentNavigationDestination(item: $selectedItem) { item in
    ///     ItemDetailView(item: item)  // No .clearNavigationBackground() needed!
    /// }
    /// ```
    ///
    @available(iOS 17.0, *)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public func persistentNavigationDestination<D: Hashable, C: View>(
        item: Binding<D?>,
        @ViewBuilder destination: @escaping (D) -> C
    ) -> some View {
        self.navigationDestination(item: item) { value in
            destination(value)
                .clearNavigationBackground()
        }
    }

    /// Registers a destination view for boolean-based navigation with automatic background clearing.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// NavigationStack {
    ///     ContentView()
    /// }
    /// .persistentNavigationDestination(isPresented: $showDetail) {
    ///     DetailView()  // No .clearNavigationBackground() needed!
    /// }
    /// ```
    ///
    @available(iOS 17.0, *)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public func persistentNavigationDestination<C: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder destination: () -> C
    ) -> some View {
        self.navigationDestination(isPresented: isPresented) {
            destination()
                .clearNavigationBackground()
        }
    }
}

#endif // canImport(UIKit)

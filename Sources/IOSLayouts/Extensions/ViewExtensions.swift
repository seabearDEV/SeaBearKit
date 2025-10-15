//
//  ViewExtensions.swift
//  IOSLayouts
//
//  Convenience extensions for common view modifiers.
//

import SwiftUI

extension View {
    /// Applies a transparent navigation background to enable persistent backgrounds.
    ///
    /// This modifier must be applied to every view in the navigation hierarchy
    /// when using `PersistentBackgroundNavigation` to maintain background visibility
    /// during navigation transitions.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// struct DetailView: View {
    ///     var body: some View {
    ///         VStack {
    ///             Text("Detail Screen")
    ///         }
    ///         .navigationTitle("Detail")
    ///         .clearNavigationBackground()
    ///     }
    /// }
    /// ```
    ///
    /// ## Technical Details
    ///
    /// Internally, this applies `.containerBackground(for: .navigation) { Color.clear }`,
    /// which makes the NavigationStack container transparent and allows the persistent
    /// background layer to remain visible.
    ///
    /// - Returns: A view with transparent navigation container background.
    ///
    /// - SeeAlso: `PersistentBackgroundNavigation`
    @available(iOS 18.0, *)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public func clearNavigationBackground() -> some View {
        self.containerBackground(for: .navigation) {
            Color.clear
        }
    }
}

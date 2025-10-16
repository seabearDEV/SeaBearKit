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
    /// ## Platform Support
    ///
    /// - **iOS 18+**: Uses `.containerBackground(for: .navigation)` for perfect transparency
    /// - **iOS 17**: Uses fallback approach with toolbar background hiding
    ///
    /// ## Technical Details
    ///
    /// On iOS 18+, this applies `.containerBackground(for: .navigation) { Color.clear }`,
    /// which makes the NavigationStack container transparent and allows the persistent
    /// background layer to remain visible.
    ///
    /// On iOS 17, uses `.toolbarBackground(.hidden)` and `.scrollContentBackground(.hidden)`
    /// as a best-effort fallback. This works well in most cases but may have minor
    /// visual differences in edge cases.
    ///
    /// - Returns: A view with transparent navigation container background.
    ///
    /// - SeeAlso: `PersistentBackgroundNavigation`
    @available(iOS 17.0, *)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public func clearNavigationBackground() -> some View {
        Group {
            if #available(iOS 18.0, *) {
                // iOS 18: Perfect solution using containerBackground
                self.containerBackground(for: .navigation) {
                    Color.clear
                }
            } else {
                // iOS 17: Fallback using toolbar background hiding
                self
                    .toolbarBackground(.hidden, for: .navigationBar)
                    .toolbarBackground(.hidden, for: .bottomBar)
                    .scrollContentBackground(.hidden)
            }
        }
    }
}

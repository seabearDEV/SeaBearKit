//
//  ViewExtensions.swift
//  SeaBearKit
//
//  Convenience extensions for common view modifiers.
//

import SwiftUI

// MARK: - Navigation Background

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
    /// - **iOS 18+**: Uses `.containerBackground(for: .navigation)` for complete transparency
    /// - **iOS 17**: Uses fallback approach with toolbar background hiding
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
                // iOS 18: Optimal solution using containerBackground
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

// MARK: - Adaptive Border

extension View {
    /// Applies a luminance-adaptive inner highlight border for visual depth.
    ///
    /// Light colors get a subtle dark top edge, dark colors get a subtle light top edge.
    /// Creates a soft "lit from above" effect that works well on colored buttons.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// RoundedRectangle(cornerRadius: 12)
    ///     .fill(buttonColor)
    ///     .adaptiveInnerBorder(color: buttonColor, cornerRadius: 12)
    /// ```
    ///
    /// - Parameters:
    ///   - color: The background color to adapt to
    ///   - cornerRadius: Corner radius matching the view's shape
    /// - Returns: View with adaptive inner border overlay
    public func adaptiveInnerBorder(color: Color, cornerRadius: CGFloat) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            color.luminance > 0.7
                                ? Color.black.opacity(0.25)
                                : Color.white.opacity(0.35),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .center
                    ),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Shake Gesture

#if canImport(UIKit)
import UIKit

extension UIDevice {
    /// Notification posted when the device is shaken.
    public static let deviceDidShakeNotification = Notification.Name(rawValue: "SeaBearKit.deviceDidShakeNotification")
}

extension UIWindow {
    /// Detects shake gesture and posts notification.
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}

/// View modifier that responds to device shake gestures.
struct DeviceShakeViewModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                action()
            }
    }
}

extension View {
    /// Performs an action when the device is shaken.
    ///
    /// Useful for undo actions, debug menus, Easter eggs, or any shake-triggered behavior.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// ContentView()
    ///     .onShake {
    ///         undoLastAction()
    ///     }
    /// ```
    ///
    /// - Parameter action: The closure to execute when shake is detected
    /// - Returns: A view that responds to shake gestures
    public func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(DeviceShakeViewModifier(action: action))
    }
}
#endif

//
//  HapticHelper.swift
//  SeaBearKit
//
//  Low-latency haptic feedback system with pre-instantiated generators.
//  Provides simple API for common haptic patterns with energy-saving support.
//

#if canImport(UIKit)
import UIKit

/// Provides low-latency haptic feedback with pre-instantiated generators.
///
/// Pre-instantiating feedback generators avoids allocation delays during interactions,
/// resulting in more responsive tactile feedback.
///
/// ## Usage
///
/// ```swift
/// // Simple impact feedback
/// HapticHelper.impact(.light)
/// HapticHelper.impact(.medium)
/// HapticHelper.impact(.rigid)
///
/// // Notification feedback
/// HapticHelper.notification(.success)
/// HapticHelper.notification(.warning)
/// HapticHelper.notification(.error)
///
/// // Selection feedback (for picker changes, etc.)
/// HapticHelper.selection()
/// ```
///
/// ## Energy Efficiency
///
/// For apps that need to conserve battery, you can check device state:
///
/// ```swift
/// if !ProcessInfo.processInfo.isLowPowerModeEnabled {
///     HapticHelper.impact(.medium)
/// }
/// ```
///
@MainActor
public enum HapticHelper {

    // MARK: - Pre-instantiated Generators

    private static let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private static let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private static let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private static let softGenerator = UIImpactFeedbackGenerator(style: .soft)
    private static let rigidGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private static let notificationGenerator = UINotificationFeedbackGenerator()
    private static let selectionGenerator = UISelectionFeedbackGenerator()

    // MARK: - Impact Feedback

    /// Triggers impact feedback with the specified style.
    ///
    /// - Parameter style: The impact feedback style
    /// - Parameter intensity: Optional intensity override (0.0 to 1.0)
    public static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat? = nil) {
        let generator: UIImpactFeedbackGenerator

        switch style {
        case .light:
            generator = lightGenerator
        case .medium:
            generator = mediumGenerator
        case .heavy:
            generator = heavyGenerator
        case .soft:
            generator = softGenerator
        case .rigid:
            generator = rigidGenerator
        @unknown default:
            generator = mediumGenerator
        }

        if let intensity = intensity {
            generator.impactOccurred(intensity: intensity)
        } else {
            generator.impactOccurred()
        }
    }

    // MARK: - Notification Feedback

    /// Triggers notification feedback for success, warning, or error states.
    ///
    /// - Parameter type: The notification feedback type
    public static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationGenerator.notificationOccurred(type)
    }

    // MARK: - Selection Feedback

    /// Triggers selection feedback for UI selection changes.
    ///
    /// Use this for picker value changes, segment control selections,
    /// or any momentary selection feedback.
    public static func selection() {
        selectionGenerator.selectionChanged()
    }

    // MARK: - Prepare (Optional)

    /// Prepares the haptic engine for imminent feedback.
    ///
    /// Call this when you know feedback will be triggered soon (e.g., on touch down)
    /// to minimize latency. The system automatically manages preparation state.
    ///
    /// - Parameter style: The impact style to prepare, or nil for all types
    public static func prepare(_ style: UIImpactFeedbackGenerator.FeedbackStyle? = nil) {
        if let style = style {
            switch style {
            case .light:
                lightGenerator.prepare()
            case .medium:
                mediumGenerator.prepare()
            case .heavy:
                heavyGenerator.prepare()
            case .soft:
                softGenerator.prepare()
            case .rigid:
                rigidGenerator.prepare()
            @unknown default:
                mediumGenerator.prepare()
            }
        } else {
            // Prepare all generators
            lightGenerator.prepare()
            mediumGenerator.prepare()
            rigidGenerator.prepare()
            notificationGenerator.prepare()
            selectionGenerator.prepare()
        }
    }
}
#endif

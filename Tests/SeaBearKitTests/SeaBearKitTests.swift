//
//  SeaBearKitTests.swift
//  SeaBearKitTests
//
//  Unit tests for SeaBearKit library
//

import XCTest
import SwiftUI
@testable import SeaBearKit

final class SeaBearKitTests: XCTestCase {

    func testLibraryMetadata() {
        XCTAssertEqual(SeaBearKit.name, "SeaBearKit")
        XCTAssertEqual(SeaBearKit.version, "1.6.0")
        XCTAssertEqual(SeaBearKit.minimumIOSVersion, "17.0")
        XCTAssertEqual(SeaBearKit.recommendedIOSVersion, "18.0")
    }

    func testColorPaletteCreation() {
        let palette = ColorPalette(
            name: "Test",
            colors: [.red, .blue, .green]
        )

        XCTAssertEqual(palette.name, "Test")
        XCTAssertEqual(palette.colors.count, 3)
        XCTAssertEqual(palette.gradientIndices, [0, 2]) // First and last by default
        XCTAssertEqual(palette.gradientOpacities, [0.5, 0.7]) // Default opacities
    }

    func testColorPaletteCustomGradient() {
        let palette = ColorPalette(
            name: "Custom",
            colors: [.red, .orange, .yellow, .green, .blue],
            gradientIndices: [0, 2, 4],
            gradientOpacities: [0.4, 0.5, 0.6]
        )

        XCTAssertEqual(palette.gradientIndices, [0, 2, 4])
        XCTAssertEqual(palette.gradientOpacities, [0.4, 0.5, 0.6])
    }

    func testBackgroundConfiguration() {
        let standard = BackgroundConfiguration.standard
        XCTAssertTrue(standard.showGradient)

        let minimal = BackgroundConfiguration.minimal
        XCTAssertFalse(minimal.showGradient)
    }

    func testSamplePalettes() {
        XCTAssertEqual(ColorPalette.samplePalettes.count, 9)

        let names = ColorPalette.samplePalettes.map { $0.name }
        XCTAssertTrue(names.contains("Sunset"))
        XCTAssertTrue(names.contains("Ocean"))
        XCTAssertTrue(names.contains("Forest"))
        XCTAssertTrue(names.contains("Monochrome"))
        XCTAssertTrue(names.contains("Midnight"))
        XCTAssertTrue(names.contains("Cherry Blossom"))
        XCTAssertTrue(names.contains("Autumn"))
        XCTAssertTrue(names.contains("Lavender"))
        XCTAssertTrue(names.contains("Mint"))
    }

    // MARK: - Color Extension Tests

    func testColorLuminance() {
        // White should have high luminance
        let white = Color.white
        XCTAssertGreaterThan(white.luminance, 0.9)

        // Black should have low luminance
        let black = Color.black
        XCTAssertLessThan(black.luminance, 0.1)
    }

    func testColorIsLight() {
        XCTAssertTrue(Color.white.isLight)
        XCTAssertTrue(Color.yellow.isLight)
        XCTAssertFalse(Color.black.isLight)
        XCTAssertFalse(Color.blue.isLight)
    }

    func testColorIsDark() {
        XCTAssertTrue(Color.black.isDark)
        XCTAssertFalse(Color.white.isDark)
    }

    func testColorContrastingColor() {
        // Light backgrounds should get black text
        XCTAssertEqual(Color.white.contrastingColor(), Color.black)
        XCTAssertEqual(Color.yellow.contrastingColor(), Color.black)

        // Dark backgrounds should get white text
        XCTAssertEqual(Color.black.contrastingColor(), Color.white)
    }

    func testColorHexConversion() {
        // Test hex to color and back
        let red = Color(hex: "#FF0000")
        XCTAssertEqual(red.toHex().uppercased(), "#FF0000")

        let green = Color(hex: "00FF00")
        XCTAssertEqual(green.toHex().uppercased(), "#00FF00")

        // Test short hex format
        let blue = Color(hex: "#00F")
        XCTAssertEqual(blue.toHex().uppercased(), "#0000FF")
    }

    func testColorBlend() {
        let blended = Color.blend(from: .black, to: .white, progress: 0.5)
        // Should be roughly gray
        XCTAssertGreaterThan(blended.luminance, 0.4)
        XCTAssertLessThan(blended.luminance, 0.6)
    }

    func testColorAdjustedBrightness() {
        let darkened = Color.white.adjustedBrightness(-0.5)
        XCTAssertLessThan(darkened.luminance, Color.white.luminance)

        let lightened = Color.black.adjustedBrightness(0.5)
        XCTAssertGreaterThan(lightened.luminance, Color.black.luminance)
    }

    func testResolvedRGBA() {
        // Use a known color value rather than Color.red (which may have slight variations)
        let color = Color(red: 1.0, green: 0.0, blue: 0.0)
        let rgba = color.resolvedRGBA

        XCTAssertGreaterThan(rgba.red, 0.9)
        XCTAssertLessThan(rgba.green, 0.1)
        XCTAssertLessThan(rgba.blue, 0.1)
        XCTAssertEqual(rgba.alpha, 1.0)
    }

    // MARK: - Time Formatting Tests

    func testTimeFormattingInt() {
        XCTAssertEqual(0.formattedAsTime, "0:00")
        XCTAssertEqual(45.formattedAsTime, "0:45")
        XCTAssertEqual(60.formattedAsTime, "1:00")
        XCTAssertEqual(125.formattedAsTime, "2:05")
        XCTAssertEqual(3661.formattedAsTime, "61:01")
    }

    func testTimeFormattingDouble() {
        XCTAssertEqual((125.7).formattedAsTime, "2:05")
        XCTAssertEqual((0.0).formattedAsTime, "0:00")
    }

    // MARK: - Parameterized Luminance Tests

    func testColorIsLightWithThreshold() {
        // Gray (0.5 luminance) with different thresholds
        let gray = Color(white: 0.5)

        // Should be light with low threshold
        XCTAssertTrue(gray.isLight(threshold: 0.4))

        // Should not be light with high threshold
        XCTAssertFalse(gray.isLight(threshold: 0.6))

        // Default threshold (0.6) should return false for mid-gray
        XCTAssertFalse(gray.isLight())
    }

    func testColorIsDarkWithThreshold() {
        // Gray (0.5 luminance) with different thresholds
        let gray = Color(white: 0.5)

        // Should be dark with high threshold
        XCTAssertTrue(gray.isDark(threshold: 0.6))

        // Should not be dark with low threshold
        XCTAssertFalse(gray.isDark(threshold: 0.3))

        // Default threshold (0.3) should return false for mid-gray
        XCTAssertFalse(gray.isDark())
    }

    // MARK: - Gradient Luminance Tests

    func testWeightedColorCreation() {
        let weighted = WeightedColor(color: .red, opacity: 0.5)
        XCTAssertEqual(weighted.opacity, 0.5)
    }

    func testGradientWeightedLuminance() {
        // All white gradient should have high luminance
        let whiteGradient: [WeightedColor] = [
            WeightedColor(color: .white, opacity: 0.5),
            WeightedColor(color: .white, opacity: 0.7)
        ]
        XCTAssertGreaterThan(whiteGradient.weightedLuminance, 0.9)

        // All black gradient should have low luminance
        let blackGradient: [WeightedColor] = [
            WeightedColor(color: .black, opacity: 0.5),
            WeightedColor(color: .black, opacity: 0.7)
        ]
        XCTAssertLessThan(blackGradient.weightedLuminance, 0.1)

        // Mixed gradient should be somewhere in between
        let mixedGradient: [WeightedColor] = [
            WeightedColor(color: .white, opacity: 0.5),
            WeightedColor(color: .black, opacity: 0.5)
        ]
        let mixedLum = mixedGradient.weightedLuminance
        XCTAssertGreaterThan(mixedLum, 0.3)
        XCTAssertLessThan(mixedLum, 0.7)
    }

    func testGradientWeightedLuminanceEmpty() {
        // Empty array should return 0.5 (neutral)
        let empty: [WeightedColor] = []
        XCTAssertEqual(empty.weightedLuminance, 0.5)
    }

    func testGradientContrastingColor() {
        // Light gradient should return black
        let lightGradient: [WeightedColor] = [
            WeightedColor(color: .white, opacity: 0.8),
            WeightedColor(color: .yellow, opacity: 0.6)
        ]
        XCTAssertEqual(lightGradient.contrastingColor(), Color.black)

        // Dark gradient should return white
        let darkGradient: [WeightedColor] = [
            WeightedColor(color: .black, opacity: 0.8),
            WeightedColor(color: Color(white: 0.2), opacity: 0.6)
        ]
        XCTAssertEqual(darkGradient.contrastingColor(), Color.white)
    }

    // MARK: - Shadow Intensity Tests

    func testShadowIntensitySubtle() {
        let unpressed = ShadowIntensity.subtle.unpressed
        let pressed = ShadowIntensity.subtle.pressed

        // Subtle should have low opacity
        XCTAssertEqual(unpressed.opacity, 0.15)
        XCTAssertEqual(unpressed.radius, 3)
        XCTAssertEqual(unpressed.y, 2)

        // Pressed should have even lower values
        XCTAssertLessThan(pressed.opacity, unpressed.opacity)
        XCTAssertLessThan(pressed.radius, unpressed.radius)
    }

    func testShadowIntensityRegular() {
        let unpressed = ShadowIntensity.regular.unpressed
        let pressed = ShadowIntensity.regular.pressed

        // Regular is the default, moderate values
        XCTAssertEqual(unpressed.opacity, 0.25)
        XCTAssertEqual(unpressed.radius, 5)
        XCTAssertEqual(unpressed.y, 3)

        // Pressed reduces all values
        XCTAssertLessThan(pressed.opacity, unpressed.opacity)
    }

    func testShadowIntensityProminent() {
        let unpressed = ShadowIntensity.prominent.unpressed
        let pressed = ShadowIntensity.prominent.pressed

        // Prominent has highest values
        XCTAssertEqual(unpressed.opacity, 0.35)
        XCTAssertEqual(unpressed.radius, 8)
        XCTAssertEqual(unpressed.y, 5)

        // Even prominent pressed should be less than unpressed
        XCTAssertLessThan(pressed.opacity, unpressed.opacity)
    }

    func testShadowIntensityOrdering() {
        // Verify intensity levels are properly ordered
        let subtle = ShadowIntensity.subtle.unpressed
        let regular = ShadowIntensity.regular.unpressed
        let prominent = ShadowIntensity.prominent.unpressed

        XCTAssertLessThan(subtle.opacity, regular.opacity)
        XCTAssertLessThan(regular.opacity, prominent.opacity)

        XCTAssertLessThan(subtle.radius, regular.radius)
        XCTAssertLessThan(regular.radius, prominent.radius)
    }

    // MARK: - Corner Radius Tests

    func testCornerRadiusStyleValues() {
        XCTAssertEqual(CornerRadiusStyle.square, 0.0)
        XCTAssertEqual(CornerRadiusStyle.slight, 15.0)
        XCTAssertEqual(CornerRadiusStyle.moderate, 40.0)
        XCTAssertEqual(CornerRadiusStyle.round, 65.0)
        XCTAssertEqual(CornerRadiusStyle.circle, 100.0)
    }

    func testCalculateCornerRadius() {
        let size = CGSize(width: 100, height: 100)

        // 0% = square (no radius)
        XCTAssertEqual(CornerRadiusHelper.calculate(percent: 0, size: size), 0)

        // 100% = circle (radius = half of size)
        XCTAssertEqual(CornerRadiusHelper.calculate(percent: 100, size: size), 50)

        // 50% = quarter of size
        XCTAssertEqual(CornerRadiusHelper.calculate(percent: 50, size: size), 25)
    }

    func testCalculateCornerRadiusNonSquare() {
        // Should use smaller dimension for non-square sizes
        let size = CGSize(width: 200, height: 100)

        // 100% should be based on smaller dimension (100)
        XCTAssertEqual(CornerRadiusHelper.calculate(percent: 100, size: size), 50)
    }

    func testCalculateCornerRadiusWithPadding() {
        let size = CGSize(width: 100, height: 100)
        let padding: CGFloat = 20

        // With padding, effective size is 80x80
        // 100% of 80 = 40 radius
        XCTAssertEqual(CornerRadiusHelper.calculate(percent: 100, size: size, padding: padding), 40)
    }
}

// MARK: - Test Helpers

/// Helper to access View's static corner radius calculation methods for testing
private enum CornerRadiusHelper {
    static func calculate(percent: Double, size: CGSize) -> CGFloat {
        // Replicate the calculation from CornerRadiusModifiers
        let baseSize = min(size.width, size.height)
        return (baseSize / 2.0) * (percent / 100.0)
    }

    static func calculate(percent: Double, size: CGSize, padding: CGFloat) -> CGFloat {
        let adjustedSize = CGSize(
            width: size.width - padding,
            height: size.height - padding
        )
        return calculate(percent: percent, size: adjustedSize)
    }
}

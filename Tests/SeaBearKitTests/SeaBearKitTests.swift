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
        XCTAssertEqual(SeaBearKit.version, "1.4.0")
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
}

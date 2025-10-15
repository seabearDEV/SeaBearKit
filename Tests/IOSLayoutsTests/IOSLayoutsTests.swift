//
//  IOSLayoutsTests.swift
//  IOSLayoutsTests
//
//  Unit tests for IOSLayouts library
//

import XCTest
@testable import IOSLayouts

final class IOSLayoutsTests: XCTestCase {

    func testLibraryMetadata() {
        XCTAssertEqual(IOSLayouts.name, "IOSLayouts")
        XCTAssertEqual(IOSLayouts.version, "1.0.0")
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
}

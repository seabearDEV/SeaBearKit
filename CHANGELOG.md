# Changelog

All notable changes to SeaBearKit will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.6.0] - 2026-04-29

### Added
- **FontGlyph**: SwiftUI view for rendering custom-font glyphs without typographic-bounds clipping (iOS only)
  - `FontGlyph(_:fontName:size:color:)` - String initializer (typical for single Unicode codepoints in icon fonts)
  - `FontGlyph(_:fontName:size:color:)` - Character convenience initializer
  - Wraps `UILabel` via `UIViewRepresentable` with `clipsToBounds = false` so glyphs whose visual extent exceeds the font's typographic line bounds (common in Font Awesome decorative styles, Material Symbols rounded variants, Phosphor, and stylized display fonts) render fully into the surrounding SwiftUI frame
  - `@MainActor`-isolated to match Swift 6 strict concurrency posture
  - Defaults `color` to `.primary`; falls back to `systemFont(ofSize:)` when the named font isn't registered

### Technical
- New `Fonts/` directory in package structure
- iOS-only (`#if canImport(UIKit)`) following the `HapticHelper` precedent; macOS variant via `NSViewRepresentable` is noted as future work
- Zero breaking changes - additive public API only

## [1.5.0] - 2026-02-03

### Added
- **Parameterized Luminance Checks**: More flexible light/dark detection
  - `Color.isLight(threshold:)` - Custom threshold for light color detection
  - `Color.isDark(threshold:)` - Custom threshold for dark color detection
  - Original `isLight` and `isDark` properties remain unchanged (use default thresholds)
- **Gradient Luminance Helper**: Calculate effective luminance of gradient overlays
  - `WeightedColor` struct - Pairs a color with its opacity weight
  - `[WeightedColor].weightedLuminance` - Opacity-weighted average luminance
  - `[WeightedColor].contrastingColor(threshold:)` - Get appropriate text color for gradients
- **Expanded Test Coverage**: 14 new tests for comprehensive coverage
  - Parameterized `isLight`/`isDark` with custom thresholds
  - Gradient luminance calculations
  - Shadow intensity values and ordering
  - Corner radius calculations and presets
  - Total tests increased from 15 to 29

### Technical
- All new APIs follow existing patterns and are fully documented
- Zero breaking changes - all existing code continues to work
- `WeightedColor` is `Sendable` for safe concurrent use

## [1.4.0] - 2026-02-03

### Added
- **Comprehensive Color Utilities**: Enhanced color manipulation for dynamic theming
  - `Color.luminance` - Perceptual brightness using ITU-R BT.709 standard
  - `Color.isDark` - Threshold-based check for dark colors
  - `Color.contrastingColor(threshold:)` - Returns black or white for text on colored backgrounds
  - `Color.adjustedBrightness(_:)` - Lighten or darken colors by amount
  - `Color.blend(from:to:progress:)` - Static method for linear color interpolation
  - `Color.toHex()` / `Color(hex:)` - Hex string conversion (supports RGB, RRGGBB, AARRGGBB formats)
  - `ResolvedRGBA` - Pre-resolved color components for efficient repeated blending
- **Haptic Feedback Helper** (iOS only): Low-latency haptic feedback system
  - `HapticHelper.impact(_:intensity:)` - Impact feedback with all styles
  - `HapticHelper.notification(_:)` - Success, warning, error feedback
  - `HapticHelper.selection()` - Selection change feedback
  - `HapticHelper.prepare(_:)` - Pre-warm haptic engine for lower latency
  - Pre-instantiated generators avoid allocation delays during interactions
- **Shake Gesture Detection** (iOS only): Simple shake handling
  - `.onShake(perform:)` - View modifier for shake gesture response
  - Useful for undo, debug menus, Easter eggs
- **Time Formatting Extensions**: Simple duration formatting
  - `Int.formattedAsTime` - Formats seconds as MM:SS (e.g., 125 → "2:05")
  - `Double.formattedAsTime` - Same for TimeInterval
- **Adaptive Inner Border**: Luminance-aware highlight effect
  - `.adaptiveInnerBorder(color:cornerRadius:)` - Light edge on dark colors, dark edge on light colors
- **New Test Coverage**: 10 new tests for color utilities and time formatting

### Changed
- Refactored `Color.isLight` to use the new `luminance` property
- Refactored `Color.blend(with:ratio:)` to use `ResolvedRGBA` for consistency
- Updated library documentation with new API examples

### Technical
- New `Utilities/` folder for non-view helpers
- All new APIs are `public` for external use
- macOS support maintained for color utilities (haptics are iOS-only)
- `ResolvedRGBA` is `Sendable` for safe concurrent use

## [1.3.0] - 2025-11-16

### Added
- **View Modifiers Package**: New essential modifiers for cleaner SwiftUI code
  - **Conditional Modifiers**: `.if(_:transform:)` for applying transformations based on conditions
    - Single-branch variant for optional transformations
    - Two-branch variant with `then:` and `else:` closures
  - **Glass Shadow System**: `.glassShadow(isPressed:intensity:)` for unified shadow application
    - Three intensity levels: `.subtle`, `.regular`, `.prominent`
    - Automatic press state handling with reduced shadow on press
    - Custom shadow variant with explicit parameters
  - **Adaptive Corner Radius**: Proportional corner radius system that scales across device sizes
    - `.adaptiveCornerRadius(_:size:)` modifier for percentage-based rounding
    - `CornerRadiusStyle` presets: `.square`, `.slight`, `.moderate`, `.round`, `.circle`
    - Helper methods: `calculateCornerRadius(percent:size:)` and variant with padding adjustment
- **Interactive Previews**: All new modifiers include comprehensive SwiftUI previews
- **Documentation**: Extensive inline documentation with usage examples for all new APIs

### Changed
- Library version updated from 1.2.0 to 1.3.0
- README updated with new "View Modifiers" section showcasing all three modifier systems
- Features section reorganized for better clarity (Navigation & Backgrounds, View Modifiers, General)
- Main module documentation updated to list new modifier APIs

### Technical
- New `Modifiers/` directory in package structure containing three focused files
- All modifiers follow SwiftUI conventions and are fully documented
- Zero breaking changes - all existing code continues to work
- Modifiers complement existing Liquid Glass design system

## [1.2.0] - 2025-10-15

### Added
- **Custom Background Support**: `PersistentBackgroundNavigation` now accepts any View as a background
  - New initializer: `init(background: () -> Background, content: () -> Content)`
  - Use images, videos, animated gradients, or any custom SwiftUI view
  - Existing palette-based API remains unchanged and fully supported
- **Enhanced Flexibility**: Background layer architecture now supports unlimited customization
- **Preview Example**: Added "Custom Background" preview demonstrating custom gradient usage

### Changed
- Refactored `PersistentBackgroundNavigation` to be generic over `Background: View`
- Palette-based initializers moved to constrained extension (`where Background == PersistentBackground`)
- Updated documentation to showcase both palette and custom background approaches

### Technical
- No breaking changes - existing code works without modification
- Custom backgrounds leverage the same ZStack architecture for consistent persistence
- Type inference ensures minimal API verbosity

## [1.1.0] - 2025-10-15

### Added
- **iOS 17 Support**: Package now supports iOS 17.0+ (previously iOS 18+ only)
  - Uses graceful degradation with fallback approach on iOS 17
  - iOS 18+ continues to use optimal `.containerBackground(for: .navigation)` API
  - iOS 17 uses `.toolbarBackground(.hidden)` fallback approach
- **Automatic Navigation Components**: Simplified navigation wrappers
  - `PersistentNavigationLink` - Drop-in NavigationLink replacement with automatic background clearing
  - `.persistentNavigationDestination(for:)` - Auto-wrapping for value-based navigation
  - `.persistentNavigationDestination(item:)` - Auto-wrapping for optional binding navigation
  - `.persistentNavigationDestination(isPresented:)` - Auto-wrapping for boolean navigation
- **Version Metadata**: Added `minimumIOSVersion` and `recommendedIOSVersion` to `SeaBearKit` struct
- **Enhanced Documentation**: Platform support matrix and iOS 17 compatibility notes

### Changed
- **Breaking**: Minimum deployment target changed from iOS 18.0 to iOS 17.0
- **Breaking**: Minimum macOS version changed from 15.0 to 14.0
- Updated all `@available` annotations from iOS 18.0 to iOS 17.0
- Enhanced `.clearNavigationBackground()` with iOS version detection and fallback
- Updated `PersistentBackgroundNavigation` to conditionally use iOS 18 APIs
- Improved documentation across README, QUICKSTART, and USAGE guides

### Fixed
- Version number in tests now matches library version (1.1.0)

## [1.0.0] - 2025-10-15

### Added
- Initial release of SeaBearKit
- **PersistentBackgroundNavigation**: NavigationStack wrapper maintaining consistent backgrounds
- **Color Palette System**: 9 built-in palettes (Sunset, Ocean, Forest, Monochrome, Midnight, Cherry Blossom, Autumn, Lavender, Mint)
- **Gradient Backgrounds**: Configurable gradients with vignette effects
- **Background Configurations**: Standard (gradient) and Minimal (system background) modes
- **View Extensions**: `.clearNavigationBackground()` modifier
- Comprehensive documentation (README, QUICKSTART, USAGE, ARCHITECTURE, IMPORTANT, DEMO, LIQUID_GLASS)
- Demo application showcasing all features
- Unit tests for core functionality
- MIT License

### Requirements
- iOS 18.0+
- Swift 6.0+
- Xcode 16.0+

---

## Platform Support

### Version 1.1.0+
- **iOS 17.0+** (iOS 18+ recommended for optimal experience)
- **macOS 14.0+**

### Version 1.0.0
- **iOS 18.0+** only
- **macOS 15.0+**

## Migration Guide

### Migrating from 1.0.0 to 1.1.0

**No Breaking Changes for iOS 18+ Users**

If your deployment target is iOS 18+, no code changes are required. The API remains identical.

**For iOS 17 Support**

1. Update your deployment target to iOS 17.0 if desired
2. No code changes required - existing code works on both iOS 17 and iOS 18
3. iOS 17 will use fallback approach automatically

**Optional: Use New Automatic Navigation**

For simplified development, consider switching to automatic navigation:

```swift
// Before (still works)
NavigationLink("Details") {
    DetailView()
        .clearNavigationBackground()
}

// After (easier)
PersistentNavigationLink("Details") {
    DetailView()  // No modifier needed!
}
```

[1.6.0]: https://github.com/seabearDEV/SeaBearKit/compare/v1.5.0...v1.6.0
[1.5.0]: https://github.com/seabearDEV/SeaBearKit/compare/v1.4.0...v1.5.0
[1.4.0]: https://github.com/seabearDEV/SeaBearKit/compare/v1.3.0...v1.4.0
[1.3.0]: https://github.com/seabearDEV/SeaBearKit/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/seabearDEV/SeaBearKit/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/seabearDEV/SeaBearKit/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/seabearDEV/SeaBearKit/releases/tag/v1.0.0

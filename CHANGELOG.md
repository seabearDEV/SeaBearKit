# Changelog

All notable changes to IOSLayouts will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-10-15

### Added
- **iOS 17 Support**: Package now supports iOS 17.0+ (previously iOS 18+ only)
  - Uses graceful degradation with fallback approach on iOS 17
  - iOS 18+ continues to use optimal `.containerBackground(for: .navigation)` API
  - iOS 17 uses `.toolbarBackground(.hidden)` fallback approach
- **Automatic Navigation Components**: Zero-friction navigation wrappers
  - `PersistentNavigationLink` - Drop-in NavigationLink replacement with automatic background clearing
  - `.persistentNavigationDestination(for:)` - Auto-wrapping for value-based navigation
  - `.persistentNavigationDestination(item:)` - Auto-wrapping for optional binding navigation
  - `.persistentNavigationDestination(isPresented:)` - Auto-wrapping for boolean navigation
- **Version Metadata**: Added `minimumIOSVersion` and `recommendedIOSVersion` to `IOSLayouts` struct
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
- Initial release of IOSLayouts
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
- **iOS 17.0+** (iOS 18+ recommended for best experience)
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

For zero-friction development, consider switching to automatic navigation:

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

[1.1.0]: https://github.com/seabearDEV/ios-layouts/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/seabearDEV/ios-layouts/releases/tag/v1.0.0

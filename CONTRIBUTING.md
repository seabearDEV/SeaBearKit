# Contributing to SeaBearKit

Thank you for your interest in contributing to SeaBearKit! This guide will help you get started.

## Code of Conduct

- Be respectful and constructive
- Focus on what's best for the community
- Show empathy towards other contributors

## Development Setup

### Prerequisites

- **Xcode 15.0+** (Xcode 16.0+ recommended)
- **Swift 6.0+**
- **macOS 14.0+** (macOS 15.0+ recommended)

### Getting Started

1. **Fork and Clone**
   ```bash
   git clone https://github.com/YOUR-USERNAME/ios-layouts.git
   cd ios-layouts
   ```

2. **Open in Xcode**
   ```bash
   open Package.swift
   ```

3. **Build the Package**
   ```bash
   swift build
   ```

4. **Run Tests**
   ```bash
   swift test
   ```

## Development Workflow

### Running Tests

Always run tests before submitting a PR:

```bash
# Run all tests
swift test

# Run tests with verbose output
swift test --verbose

# Run specific test
swift test --filter SeaBearKitTests.testLibraryMetadata
```

**All tests must pass before submitting a PR.**

### Testing Locally in an App

To test your changes in a real app:

```swift
// In your test app's Package.swift
dependencies: [
    .package(path: "/path/to/your/ios-layouts")
]
```

Or in Xcode: **File → Add Package Dependencies → Add Local**

### Preview Your Changes

Use Xcode Previews for quick iteration:

1. Open `Sources/SeaBearKit/Navigation/PersistentBackgroundNavigation.swift`
2. Press `⌥⌘↩` to open Canvas
3. Test your changes interactively

## Code Standards

### Swift Style

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use Swift 6 strict concurrency where applicable
- Prefer clarity over brevity
- Add documentation comments for all public APIs

### Documentation

Every public API must have:

```swift
/// Brief one-line description.
///
/// Detailed explanation of what this does and why.
///
/// ## Usage
///
/// ```swift
/// // Code example
/// ```
///
/// - Parameters:
///   - parameter: Description
/// - Returns: Description
public func yourFunction(parameter: Type) -> ReturnType {
    // implementation
}
```

### Platform Support

- **Minimum**: iOS 17.0, macOS 14.0
- **Recommended**: iOS 18.0+
- Use `@available` annotations appropriately
- Test on both iOS 17 and iOS 18 when adding features

### Fallback Pattern

When using iOS 18+ APIs, provide iOS 17 fallbacks:

```swift
@available(iOS 17.0, *)
public func yourFunction() -> some View {
    if #available(iOS 18.0, *) {
        // iOS 18: Optimal implementation
        modernAPI()
    } else {
        // iOS 17: Fallback implementation
        fallbackAPI()
    }
}
```

## Adding Features

### 1. Planning

Before coding, consider:
- Does this fit the library's scope?
- Will it work on iOS 17 and iOS 18?
- Is there a simpler approach?
- How will this be documented?

### 2. Implementation

Follow this checklist:

- [ ] Write the feature code
- [ ] Add `@available` annotations
- [ ] Provide iOS 17 fallback if using iOS 18 APIs
- [ ] Add comprehensive documentation comments
- [ ] Update relevant `.md` files (README, USAGE, etc.)
- [ ] Add unit tests
- [ ] Test on iOS 17 and iOS 18
- [ ] Update CHANGELOG.md

### 3. Testing Requirements

Add tests for:
- Basic functionality
- Edge cases
- iOS version compatibility (if applicable)

Example:
```swift
func testNewFeature() {
    let result = yourNewFeature()
    XCTAssertEqual(result, expectedValue)
}
```

### 4. Documentation Updates

Update these files as needed:
- **CHANGELOG.md**: Add entry under `[Unreleased]`
- **README.md**: Update if adding major feature
- **USAGE.md**: Add usage examples
- **QUICKSTART.md**: Update if affecting quick start
- **IMPORTANT.md**: Document any gotchas or requirements

## Pull Request Process

### Before Submitting

1. **Run tests**: `swift test` ✅
2. **Build succeeds**: `swift build` ✅
3. **No warnings**: Clean build output ✅
4. **Documentation updated**: All relevant files ✅
5. **CHANGELOG updated**: Entry added ✅

### PR Description Template

```markdown
## Description
Brief description of what this PR does.

## Motivation
Why is this change needed?

## Changes
- Change 1
- Change 2

## Testing
- [ ] All tests pass
- [ ] Tested on iOS 17
- [ ] Tested on iOS 18
- [ ] Added new tests (if applicable)

## Documentation
- [ ] Updated CHANGELOG.md
- [ ] Updated relevant documentation files
- [ ] Added code examples

## Screenshots (if UI changes)
<!-- Add before/after screenshots -->
```

### Review Process

1. **Automated checks**: Tests must pass
2. **Code review**: Maintainer will review
3. **Feedback**: Address any requested changes
4. **Approval**: Maintainer approves
5. **Merge**: Maintainer merges

## Common Contribution Areas

### 🟢 Great First Contributions

- Improve documentation
- Add code examples
- Fix typos
- Add missing tests
- Improve error messages

### 🟡 Intermediate Contributions

- Add new color palettes
- Improve iOS 17 fallbacks
- Add new convenience methods
- Performance optimizations

### 🔴 Advanced Contributions

- New navigation patterns
- Architecture improvements
- Cross-platform support (visionOS, tvOS)

## Reporting Issues

### Bug Reports

Include:
- iOS version
- Xcode version
- Minimal reproduction code
- Expected vs actual behavior
- Screenshots/videos if visual

### Feature Requests

Include:
- Use case description
- Why existing features don't work
- Proposed API (if you have ideas)
- Platform considerations

## Questions?

- Check existing documentation first
- Search existing issues
- Open a new issue with the "question" label

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Recognition

Contributors will be recognized in:
- CHANGELOG.md for significant contributions
- GitHub contributors page

Thank you for contributing to SeaBearKit! 🎉

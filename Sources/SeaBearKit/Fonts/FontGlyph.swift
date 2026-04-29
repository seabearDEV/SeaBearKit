//
//  FontGlyph.swift
//  SeaBearKit
//
//  Renders a glyph in a custom font without typographic-bounds clipping.
//

#if canImport(UIKit)
import SwiftUI
import UIKit

/// Renders a glyph in a custom font without the typographic-bounds clipping
/// that affects SwiftUI's `Text`.
///
/// SwiftUI's `Text` clips its rendering to the font's typographic line bounds
/// (ascent + descent). Icon fonts (Font Awesome decorative styles, Material
/// Symbols rounded variants, Phosphor, custom icon sets) and stylized display
/// fonts often have glyphs whose visual extent exceeds those bounds, so the
/// tops or bottoms of glyphs get visibly cut off. `.frame()`, `.fixedSize()`,
/// and `.padding()` don't help — the clipping happens inside the Text view's
/// drawing context, before layout modifiers apply.
///
/// `FontGlyph` wraps a `UILabel` with `clipsToBounds = false` so the glyph's
/// full visual extent renders into the SwiftUI frame you give it.
///
/// ## Usage
///
/// ```swift
/// // Single Unicode codepoint (typical for icon fonts)
/// FontGlyph("\u{f015}", fontName: "FontAwesome7Pro-Solid", size: 32)
///
/// // Single character
/// FontGlyph(Character("A"), fontName: "MyDisplayFont-Black", size: 48)
///
/// // Any string (rare for icons but supported)
/// FontGlyph("AB", fontName: "MyDisplayFont-Black", size: 48)
/// ```
///
/// ## Sizing
///
/// `FontGlyph` does not constrain its own size. Wrap it in a `.frame()` to
/// reserve layout space and align with surrounding content. A safe rule of
/// thumb for icon fonts is ~2× font size in width and ~1.75× in height as
/// headroom for visual overshoot:
///
/// ```swift
/// FontGlyph(glyph, fontName: psName, size: 32)
///     .frame(width: 64, height: 56, alignment: .center)
/// ```
///
/// ## Color
///
/// Pass the desired color via the `color` parameter (defaults to `.primary`).
/// `FontGlyph` is `UIView`-backed, so SwiftUI's `.foregroundStyle()` does not
/// apply.
///
/// ```swift
/// FontGlyph("\u{f015}", fontName: ps, size: 32, color: .blue)
/// ```
///
/// ## Font Naming
///
/// `fontName` should be the font's **PostScript name** (e.g.
/// `"FontAwesome7Pro-Solid"`), not the family name. PostScript names are
/// unambiguous when several weights share a family. They can be discovered
/// at runtime by enumerating `UIFont.fontNames(forFamilyName:)` for each
/// loaded family.
///
/// ## Platform Support
///
/// iOS-only as of this version. A future macOS variant via `NSViewRepresentable`
/// is possible but not yet implemented; on macOS the same clipping behavior
/// exists in `Text` and would need an analogous `NSTextField`-based wrapper.
///
@MainActor
public struct FontGlyph: UIViewRepresentable {

    public let glyph: String
    public let fontName: String
    public let size: CGFloat
    public let color: Color

    /// Creates a `FontGlyph` rendering an arbitrary string in the given custom font.
    /// - Parameters:
    ///   - glyph: The string to render. For icon fonts this is typically a single
    ///     Unicode codepoint (`"\u{f015}"`).
    ///   - fontName: The PostScript name of the font (not the family name).
    ///   - size: Point size for the font.
    ///   - color: Text color. Defaults to `.primary`.
    public init(_ glyph: String, fontName: String, size: CGFloat, color: Color = .primary) {
        self.glyph = glyph
        self.fontName = fontName
        self.size = size
        self.color = color
    }

    /// Creates a `FontGlyph` rendering a single character.
    /// - Parameters:
    ///   - glyph: The character to render.
    ///   - fontName: The PostScript name of the font.
    ///   - size: Point size for the font.
    ///   - color: Text color. Defaults to `.primary`.
    public init(_ glyph: Character, fontName: String, size: CGFloat, color: Color = .primary) {
        self.init(String(glyph), fontName: fontName, size: size, color: color)
    }

    public func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        label.lineBreakMode = .byClipping
        label.clipsToBounds = false
        label.layer.masksToBounds = false
        label.adjustsFontSizeToFitWidth = false
        return label
    }

    public func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.font = UIFont(name: fontName, size: size) ?? .systemFont(ofSize: size)
        uiView.text = glyph
        uiView.textColor = UIColor(color)
    }
}
#endif

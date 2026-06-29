import SharedUI
import UIKit
import XCTest

final class TypographyStyleFontTests: XCTestCase {
    // All Figma token styles, used to drive size/line-height invariants.
    private let allStyles: [TypographyStyle] = [
        Typography.Display.large, Typography.Display.medium, Typography.Display.small,
        Typography.Heading.large, Typography.Heading.medium, Typography.Heading.small, Typography.Heading.xSmall,
        Typography.Body.large, Typography.Body.medium, Typography.Body.mediumStrikethrough, Typography.Body.small,
        Typography.Label.small, Typography.Label.smallBold,
        Typography.Link.medium, Typography.Link.small,
    ]

    override func setUp() {
        super.setUp()
        // Brand (Display) styles resolve via UIFont(name:), so the bundled face must be registered.
        try? FontManager.registerAll()
    }

    func test_uiFont_pointSize_matchesTokenFontSize() {
        for style in allStyles {
            XCTAssertEqual(style.uiFont.pointSize, style.fontSize, "pointSize must equal token fontSize")
        }
    }

    func test_weightMapping_400isRegular_500isMedium() {
        XCTAssertEqual(UIFont.Weight(tokenWeight: 400), .regular)
        XCTAssertEqual(UIFont.Weight(tokenWeight: 500), .medium)
        // default fallback
        XCTAssertEqual(UIFont.Weight(tokenWeight: 123), .regular)
    }

    func test_sfProStyle_resolvesToSystemFont_notNamedFont() {
        // "SF Pro" is not a registerable named font: UIFont(name:) must return nil.
        XCTAssertNil(UIFont(name: Primitives.Typography.fontFamilyPrimaryIos, size: 16))
        // Yet the bridge still returns a valid font for an SF Pro token (via systemFont).
        let style = Typography.Body.medium
        XCTAssertEqual(style.fontFamily, Primitives.Typography.fontFamilyPrimaryIos)
        XCTAssertEqual(style.uiFont.pointSize, style.fontSize)
    }

    func test_sfProToken_appliesMappedWeightTrait() {
        // Heading uses weight 500 -> .medium; Body uses 400 -> .regular.
        let headingTrait = weightTrait(of: Typography.Heading.large.uiFont)
        let bodyTrait = weightTrait(of: Typography.Body.medium.uiFont)
        XCTAssertEqual(headingTrait, UIFont.Weight.medium.rawValue, accuracy: 0.001)
        XCTAssertEqual(bodyTrait, UIFont.Weight.regular.rawValue, accuracy: 0.001)
    }

    func test_brandFont_registers_andResolves() throws {
        try FontManager.registerAll()
        let brand = UIFont(name: FontNames.libreBaskerville.rawValue, size: 24)
        XCTAssertNotNil(brand, "Libre Baskerville must resolve after FontManager.registerAll()")
        XCTAssertEqual(brand?.pointSize, 24)
    }

    func test_brandStyle_usesBrandFont() throws {
        try FontManager.registerAll()
        let style = Typography.Display.large
        XCTAssertEqual(style.fontFamily, Primitives.Typography.fontFamilyBrand)
        XCTAssertEqual(style.uiFont.pointSize, style.fontSize)
        // The resolved family name should be the brand family, not the system font.
        XCTAssertEqual(style.uiFont.familyName, Primitives.Typography.fontFamilyBrand)
    }

    func test_everyToken_lineHeightGreaterThanFontSize() {
        // Bridge passes lineHeight into the lineSpacing slot; build(...) lineSpacing - pointSize must be >= 0.
        for style in allStyles {
            XCTAssertGreaterThan(style.lineHeight, style.fontSize, "lineHeight must exceed fontSize so lineSpacing stays >= 0")
        }
    }

    // MARK: - Helpers

    private func weightTrait(of font: UIFont) -> CGFloat {
        let traits = font.fontDescriptor.object(forKey: .traits) as? [UIFontDescriptor.TraitKey: Any]
        return (traits?[.weight] as? CGFloat) ?? .nan
    }
}

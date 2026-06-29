import SharedUI
import UIKit
import XCTest

final class TypographyProviderTokenTests: XCTestCase {
    private let provider = TypographyProvider()

    override func setUp() {
        super.setUp()
        // Brand (Display) and legacy faces resolve through UIFont(name:), so they must be registered.
        try? FontManager.registerAll()
    }

    func test_display_matchesTokens() {
        assertMatches(provider.display.large, Typography.Display.large)
        assertMatches(provider.display.medium, Typography.Display.medium)
        assertMatches(provider.display.small, Typography.Display.small)
    }

    func test_heading_matchesTokens() {
        assertMatches(provider.heading.large, Typography.Heading.large)
        assertMatches(provider.heading.medium, Typography.Heading.medium)
        assertMatches(provider.heading.small, Typography.Heading.small)
        assertMatches(provider.heading.xSmall, Typography.Heading.xSmall)
    }

    func test_body_matchesTokens() {
        assertMatches(provider.body.large, Typography.Body.large)
        assertMatches(provider.body.medium, Typography.Body.medium)
        assertMatches(provider.body.mediumStrikethrough, Typography.Body.mediumStrikethrough)
        assertMatches(provider.body.small, Typography.Body.small)
    }

    func test_label_matchesTokens() {
        assertMatches(provider.label.small, Typography.Label.small)
        assertMatches(provider.label.smallBold, Typography.Label.smallBold)
    }

    func test_link_matchesTokens() {
        assertMatches(provider.link.medium, Typography.Link.medium)
        assertMatches(provider.link.small, Typography.Link.small)
    }

    // MARK: - Helpers

    private func assertMatches(
        _ themed: ThemedTypographyStyle,
        _ token: TypographyStyle,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(themed.uiFont.pointSize, token.fontSize, "pointSize", file: file, line: line)
        // Weight traits are only meaningful for the system font (SF Pro); the custom brand
        // face carries its own descriptor weight, so we only assert the mapped weight there.
        if token.fontFamily == Primitives.Typography.fontFamilyPrimaryIos {
            XCTAssertEqual(
                weightTrait(of: themed.uiFont),
                UIFont.Weight(tokenWeight: token.fontWeight).rawValue,
                accuracy: 0.001,
                "weight",
                file: file,
                line: line
            )
        }
    }

    private func weightTrait(of font: UIFont) -> CGFloat {
        let traits = font.fontDescriptor.object(forKey: .traits) as? [UIFontDescriptor.TraitKey: Any]
        return (traits?[.weight] as? CGFloat) ?? .nan
    }
}

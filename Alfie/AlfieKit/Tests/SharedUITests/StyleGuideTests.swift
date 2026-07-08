import XCTest
@testable import SharedUI

final class StyleGuideTests: XCTestCase {
    // MARK: - TypographyStyle → UIFont bridge

    func testUIFontUsesTokenSize() {
        XCTAssertEqual(Typography.Body.medium.uiFont.pointSize, Typography.Body.medium.fontSize)
        XCTAssertEqual(Typography.Heading.large.uiFont.pointSize, Typography.Heading.large.fontSize)
    }

    func testRegularWeightTokenMapsToRegularSystemFont() {
        // Body.medium is weight 400 → .regular
        XCTAssertEqual(
            Typography.Body.medium.uiFont,
            .systemFont(ofSize: Typography.Body.medium.fontSize, weight: .regular)
        )
    }

    func testMediumWeightTokenMapsToMediumSystemFont() {
        // Heading.large is weight 500 → .medium
        XCTAssertEqual(
            Typography.Heading.large.uiFont,
            .systemFont(ofSize: Typography.Heading.large.fontSize, weight: .medium)
        )
    }

    func testSFProFamilyResolvesToSystemFont() {
        // The primary iOS family is the system typeface, so the token font must equal a system font.
        let font = Typography.Body.small.uiFont
        XCTAssertEqual(font.familyName, UIFont.systemFont(ofSize: font.pointSize).familyName)
    }
}

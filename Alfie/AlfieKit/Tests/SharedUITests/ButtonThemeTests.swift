import SwiftUI
import XCTest
@testable import SharedUI

final class ButtonThemeTests: XCTestCase {
    func test_primary_sourcesSemanticButtonTokens() {
        let spec = ButtonTheme.primary.spec
        XCTAssertEqual(spec.backgroundColor, Theme.buttonPrimaryBackgroundPrimaryDefault)
        XCTAssertEqual(spec.backgroundDisabledColor, Theme.buttonPrimaryBackgroundPrimaryDisabled)
        XCTAssertEqual(spec.textColor, Theme.buttonPrimaryContentPrimaryDefault)
        XCTAssertEqual(spec.textDisabledColor, Theme.buttonPrimaryContentPrimaryDisabled)
        XCTAssertEqual(spec.borderColor, Theme.buttonPrimaryStrokePrimaryDefault)
        XCTAssertEqual(spec.borderDisabledColor, Theme.buttonPrimaryStrokePrimaryDisabled)
        XCTAssertEqual(spec.backgroundPressedColor, Primitives.Colours.neutrals500)
        XCTAssertEqual(spec.textPressedColor, Primitives.Colours.neutrals0)
        XCTAssertEqual(spec.borderPressedColor, Primitives.Colours.neutrals500)
    }

    func test_secondary_sourcesSemanticButtonTokens() {
        let spec = ButtonTheme.secondary.spec
        XCTAssertEqual(spec.backgroundColor, Theme.buttonSecondaryBackgroundSecondaryDefault)
        XCTAssertEqual(spec.backgroundDisabledColor, Theme.buttonSecondaryBackgroundSecondaryDisabled)
        XCTAssertEqual(spec.textColor, Theme.buttonSecondaryContentSecondaryDefault)
        XCTAssertEqual(spec.textDisabledColor, Theme.buttonSecondaryContentSecondaryDisabled)
        XCTAssertEqual(spec.borderColor, Theme.buttonSecondaryStrokeSecondaryDefault)
        XCTAssertEqual(spec.borderDisabledColor, Theme.buttonSecondaryStrokeSecondaryDisabled)
        XCTAssertEqual(spec.backgroundPressedColor, Primitives.Colours.neutrals100)
        XCTAssertEqual(spec.textPressedColor, Primitives.Colours.neutrals500)
        XCTAssertEqual(spec.borderPressedColor, Primitives.Colours.neutrals500)
    }

    func test_tertiary_sourcesSemanticButtonTokens() {
        let spec = ButtonTheme.tertiary.spec
        XCTAssertEqual(spec.backgroundColor, Theme.buttonTerciaryBackgroundTerciaryDefault)
        XCTAssertEqual(spec.backgroundDisabledColor, Theme.buttonTerciaryBackgroundTerciaryDisabled)
        XCTAssertEqual(spec.textColor, Theme.buttonTerciaryContentTerciaryDefault)
        XCTAssertEqual(spec.textDisabledColor, Theme.buttonTerciaryContentTerciaryDisabled)
        XCTAssertEqual(spec.borderColor, Theme.buttonTerciaryStrokeTerciaryDefault)
        XCTAssertEqual(spec.borderDisabledColor, Theme.buttonTerciaryStrokeTerciaryDisabled)
        XCTAssertEqual(spec.backgroundPressedColor, Primitives.Colours.neutrals100)
        XCTAssertEqual(spec.textPressedColor, Primitives.Colours.neutrals500)
        XCTAssertEqual(spec.borderPressedColor, Primitives.Colours.neutrals100)
    }

    func test_underline_sourcesSemanticLinkTokensForText() {
        let spec = ButtonTheme.underline.spec
        XCTAssertEqual(spec.textColor, Theme.linkLinkPrimaryDefault)
        XCTAssertEqual(spec.textDisabledColor, Theme.linkLinkPrimaryDisabled)
        XCTAssertEqual(spec.textPressedColor, Primitives.Colours.neutrals500)
    }

    func test_underline_hasTransparentBackgroundAndBorderInEveryState() {
        let spec = ButtonTheme.underline.spec
        XCTAssertEqual(spec.backgroundColor, Theme.buttonTerciaryBackgroundTerciaryDefault)
        XCTAssertEqual(spec.backgroundDisabledColor, Theme.buttonTerciaryBackgroundTerciaryDisabled)
        XCTAssertEqual(spec.backgroundPressedColor, Theme.buttonTerciaryBackgroundTerciaryDefault)
        XCTAssertEqual(spec.borderColor, Theme.buttonTerciaryStrokeTerciaryDefault)
        XCTAssertEqual(spec.borderDisabledColor, Theme.buttonTerciaryStrokeTerciaryDisabled)
        XCTAssertEqual(spec.borderPressedColor, Theme.buttonTerciaryStrokeTerciaryDefault)
    }
}

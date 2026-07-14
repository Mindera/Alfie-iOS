import SwiftUI
import XCTest
@testable import SharedUI

/// Pins each `ButtonTheme` variant to the design tokens it must source colors from, so a future
/// token regeneration (or an accidental edit) that re-points a mapping is caught. Default/disabled
/// colors come from the semantic `Theme.button*` layer; the pressed state and the underline
/// background/border have no semantic token and intentionally stay on `Primitives.Colours.*`.
final class ButtonThemeTests: XCTestCase {
    func test_primary_sourcesSemanticButtonTokens() {
        let spec = ButtonTheme.primary.spec
        XCTAssertEqual(spec.backgroundColor, Theme.buttonPrimaryBackgroundPrimaryDefault)
        XCTAssertEqual(spec.backgroundDisabledColor, Theme.buttonPrimaryBackgroundPrimaryDisabled)
        XCTAssertEqual(spec.textColor, Theme.buttonPrimaryContentPrimaryDefault)
        XCTAssertEqual(spec.textDisabledColor, Theme.buttonPrimaryContentPrimaryDisabled)
        XCTAssertEqual(spec.borderColor, Theme.buttonPrimaryStrokePrimaryDefault)
        XCTAssertEqual(spec.borderDisabledColor, Theme.buttonPrimaryStrokePrimaryDisabled)
        // Pressed: no semantic token — primitives retained.
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
        // Underline has no semantic button group → text tracks the semantic link tokens.
        XCTAssertEqual(spec.textColor, Theme.linkLinkPrimaryDefault)
        XCTAssertEqual(spec.textDisabledColor, Theme.linkLinkPrimaryDisabled)
        // Pressed text + the (invisible) background/border have no matching token — primitives retained.
        XCTAssertEqual(spec.textPressedColor, Primitives.Colours.neutrals500)
        XCTAssertEqual(spec.backgroundColor, Primitives.Colours.neutrals0)
        XCTAssertEqual(spec.backgroundDisabledColor, Primitives.Colours.neutrals0)
        XCTAssertEqual(spec.backgroundPressedColor, Primitives.Colours.neutrals0)
        XCTAssertEqual(spec.borderColor, Primitives.Colours.neutrals0)
        XCTAssertEqual(spec.borderDisabledColor, Primitives.Colours.neutrals0)
        XCTAssertEqual(spec.borderPressedColor, Primitives.Colours.neutrals0)
    }
}

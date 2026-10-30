import SwiftUI
import XCTest
@testable import SharedUI

final class ButtonThemeTests: XCTestCase {
    func test_primary_spec_uses_primary_button_tokens() {
        let spec = ButtonTheme.primary.spec
        XCTAssertEqual(spec.backgroundColor, Theme.buttonPrimaryBackgroundPrimaryDefault)
        XCTAssertEqual(spec.backgroundDisabledColor, Theme.buttonPrimaryBackgroundPrimaryDisabled)
        XCTAssertEqual(spec.textColor, Theme.buttonPrimaryContentPrimaryDefault)
        XCTAssertEqual(spec.textDisabledColor, Theme.buttonPrimaryContentPrimaryDisabled)
        XCTAssertEqual(spec.borderColor, Theme.buttonPrimaryStrokePrimaryDefault)
        XCTAssertEqual(spec.borderDisabledColor, Theme.buttonPrimaryStrokePrimaryDisabled)
    }

    func test_secondary_spec_uses_secondary_button_tokens() {
        let spec = ButtonTheme.secondary.spec
        XCTAssertEqual(spec.backgroundColor, Theme.buttonSecondaryBackgroundSecondaryDefault)
        XCTAssertEqual(spec.backgroundDisabledColor, Theme.buttonSecondaryBackgroundSecondaryDisabled)
        XCTAssertEqual(spec.textColor, Theme.buttonSecondaryContentSecondaryDefault)
        XCTAssertEqual(spec.textDisabledColor, Theme.buttonSecondaryContentSecondaryDisabled)
        XCTAssertEqual(spec.borderColor, Theme.buttonSecondaryStrokeSecondaryDefault)
        XCTAssertEqual(spec.borderDisabledColor, Theme.buttonSecondaryStrokeSecondaryDisabled)
    }

    func test_tertiary_spec_uses_tertiary_button_tokens() {
        let spec = ButtonTheme.tertiary.spec
        XCTAssertEqual(spec.backgroundColor, Theme.buttonTerciaryBackgroundTerciaryDefault)
        XCTAssertEqual(spec.backgroundDisabledColor, Theme.buttonTerciaryBackgroundTerciaryDisabled)
        XCTAssertEqual(spec.textColor, Theme.buttonTerciaryContentTerciaryDefault)
        XCTAssertEqual(spec.textDisabledColor, Theme.buttonTerciaryContentTerciaryDisabled)
        XCTAssertEqual(spec.borderColor, Theme.buttonTerciaryStrokeTerciaryDefault)
        XCTAssertEqual(spec.borderDisabledColor, Theme.buttonTerciaryStrokeTerciaryDisabled)
    }

    func test_underline_text_uses_link_tokens() {
        let spec = ButtonTheme.underline.spec
        XCTAssertEqual(spec.textColor, Theme.linkLinkPrimaryDefault)
        XCTAssertEqual(spec.textDisabledColor, Theme.linkLinkPrimaryDisabled)
    }

    func test_underline_background_and_border_reuse_tertiary_tokens_in_every_state() {
        let spec = ButtonTheme.underline.spec
        XCTAssertEqual(spec.backgroundColor, Theme.buttonTerciaryBackgroundTerciaryDefault)
        XCTAssertEqual(spec.backgroundDisabledColor, Theme.buttonTerciaryBackgroundTerciaryDisabled)
        XCTAssertEqual(spec.borderColor, Theme.buttonTerciaryStrokeTerciaryDefault)
        XCTAssertEqual(spec.borderDisabledColor, Theme.buttonTerciaryStrokeTerciaryDisabled)
    }
}

import SwiftUI
import XCTest
@testable import SharedUI

final class DesignSystemSemanticTokensTests: XCTestCase {
    func test_color_vendsTheSemanticColourTokens() {
        XCTAssertEqual(DesignSystem.shared.color.surfaceBackgroundPrimary, Primitives.Colours.neutrals0)
        XCTAssertEqual(DesignSystem.shared.color.contentContentPrimary, Primitives.Colours.neutrals800)
    }

    func test_sizing_vendsTheSemanticSizingTokens() {
        XCTAssertEqual(DesignSystem.shared.sizing.spacingSpacingMd, 16)
        XCTAssertEqual(DesignSystem.shared.sizing.radiusSoft, 4)
        XCTAssertEqual(DesignSystem.shared.sizing.radiusRounded, 1000)
        XCTAssertEqual(DesignSystem.shared.sizing.iconsIconMedium, 24)
    }

    func test_environmentTheme_vendsTheSameSemanticTokens() {
        let theme = EnvironmentValues().theme
        XCTAssertEqual(theme.color.borderSoft, Primitives.Colours.neutrals200)
        XCTAssertEqual(theme.sizing.radiusStrong, 16)
    }
}

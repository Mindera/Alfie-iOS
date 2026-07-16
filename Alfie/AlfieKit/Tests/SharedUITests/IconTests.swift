import SwiftUI
import UIKit
import XCTest
@testable import SharedUI

/// Appearance coverage for the Figma-reconciled icon set (ALFMOB-426). The repo's snapshot suite is
/// disabled, so these assert resolution + catalog completeness instead: every `Icon` case must resolve
/// to a bundled asset (no SF Symbols remain — the Figma "SF Symbol - iOS" section supplies the glyphs).
final class IconTests: XCTestCase {

    // MARK: - Asset resolution

    func test_everyIcon_resolvesToBundledAsset() {
        for icon in Icon.allCases {
            XCTAssertNotEqual(
                icon.uiImage.size,
                .zero,
                "Icon.\(icon) (asset '\(icon.assetName)') did not resolve to a bundled asset — is it in Icons.xcassets?"
            )
        }
    }

    /// Locks the alias mapping: a case whose unique raw value intentionally resolves to a shared glyph.
    /// Without this, dropping the `assetName` switch would go unnoticed unless a literal `reload`
    /// imageset were ever added.
    func test_aliasedIcon_resolvesToSharedAssetDistinctFromRawValue() {
        XCTAssertEqual(Icon.reload.assetName, "loading")
        XCTAssertNotEqual(Icon.reload.assetName, Icon.reload.rawValue)
    }

    func test_iconSetCount() {
        XCTAssertEqual(Icon.allCases.count, 61)
    }

    // MARK: - ThemedIcon size tokens

    func test_themedIconSize_mapsToSizingTokens() {
        XCTAssertEqual(ThemedIcon.Size.small.dimension, Sizing.iconsIconSmall)
        XCTAssertEqual(ThemedIcon.Size.medium.dimension, Sizing.iconsIconMedium)
        XCTAssertEqual(ThemedIcon.Size.large.dimension, Sizing.iconsIconLarge)
        XCTAssertEqual(ThemedIcon.Size.xlarge.dimension, Sizing.iconsIconXlarge)
    }
}

import SwiftUI
import UIKit
import XCTest
@testable import SharedUI

/// Appearance coverage for the Figma-reconciled icon set (ALFMOB-426). The repo's snapshot suite is
/// disabled, so these assert resolution + catalog completeness instead: in-scope icons must resolve to
/// a bundled asset, fallbacks to a valid SF Symbol.
final class IconTests: XCTestCase {
    private var assetBackedIcons: [Icon] { Icon.allCases.filter { !$0.usesSystemSymbol } }
    private var fallbackIcons: [Icon] { Icon.allCases.filter { $0.usesSystemSymbol } }

    // MARK: - Asset-backed (in-scope Figma icons)

    func test_assetBackedIcons_resolveToBundledAsset() {
        for icon in assetBackedIcons {
            XCTAssertNotEqual(
                icon.uiImage.size,
                .zero,
                "Icon.\(icon) (asset '\(icon.assetName)') did not resolve to a bundled asset — is it in Icons.xcassets?"
            )
        }
    }

    /// Locks the alias mapping: two cases with distinct (unique) raw values that intentionally
    /// resolve to one shared glyph. Without this, dropping the `assetName` switch would go unnoticed
    /// unless a literal `info`/`reload` imageset were ever added.
    func test_aliasedIcons_resolveToSharedAssetDistinctFromRawValue() {
        XCTAssertEqual(Icon.info.assetName, "help")
        XCTAssertEqual(Icon.reload.assetName, "loading")
        XCTAssertNotEqual(Icon.info.assetName, Icon.info.rawValue)
        XCTAssertNotEqual(Icon.reload.assetName, Icon.reload.rawValue)
    }

    // MARK: - Fallbacks (no in-scope Figma equivalent)

    func test_fallbackIcons_resolveToValidSystemSymbol() {
        for icon in fallbackIcons {
            XCTAssertNotNil(
                UIImage(systemName: icon.rawValue),
                "Fallback Icon.\(icon) raw value '\(icon.rawValue)' is not a valid SF Symbol"
            )
        }
    }

    /// Locks the design-approved fallback set (plan.md D2). Changing the icon set should force an
    /// explicit update here, not silently regress an in-scope icon into an SF Symbol.
    func test_fallbackSet_matchesDesignApprovedList() {
        let expected: Set<Icon> = [
            .aCircle, .arrowLeft, .chartDownTrend, .chartUpTrend, .chat2, .closeCircleFill,
            .location, .logIn, .store, .zCircle,
        ]
        XCTAssertEqual(Icon.systemSymbolFallbacks, expected)
    }

    // MARK: - Whole-set guards

    func test_everyIcon_producesNonEmptyImage() {
        for icon in Icon.allCases {
            XCTAssertNotEqual(icon.uiImage.size, .zero, "Icon.\(icon) produced an empty image")
        }
    }

    func test_iconSetComposition() {
        XCTAssertEqual(assetBackedIcons.count, 50, "Expected 50 asset-backed in-scope icons")
        XCTAssertEqual(fallbackIcons.count, 10, "Expected 10 SF-Symbol fallbacks")
        XCTAssertEqual(Icon.allCases.count, 60)
    }

    // MARK: - ThemedIcon size tokens

    func test_themedIconSize_mapsToSizingTokens() {
        XCTAssertEqual(ThemedIcon.Size.small.dimension, Sizing.iconsIconSmall)
        XCTAssertEqual(ThemedIcon.Size.medium.dimension, Sizing.iconsIconMedium)
        XCTAssertEqual(ThemedIcon.Size.large.dimension, Sizing.iconsIconLarge)
        XCTAssertEqual(ThemedIcon.Size.xlarge.dimension, Sizing.iconsIconXlarge)
    }
}

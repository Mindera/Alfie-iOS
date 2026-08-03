import Foundation
import Model
import SwiftUI

extension VerticalProductCardConfiguration {
    // swiftlint:disable vertical_whitespace_between_cases
    var cardSize: CardIntrinsicSize {
        switch size {
        case .small:
            .fixed(size: 130)
        case .medium,
             .large: // swiftlint:disable:this indentation_width
            .flexible
        }
    }

    var verticalInterSpacing: CGFloat {
        // Figma: 8pt between image, details and price for the PLP grid/list cards.
        switch size {
        case .small,
             .medium,
             .large: // swiftlint:disable:this indentation_width
            Primitives.Spacing.spacing8
        }
    }

    var priceConfiguration: PriceConfiguration {
        switch size {
        case .small:
            .init(preferredDistribution: .horizontal, size: .small, textAlignment: .leading)
        case .medium:
            .init(preferredDistribution: .horizontal, size: .large, textAlignment: .leading)
        case .large:
            .init(preferredDistribution: .vertical, size: .large, textAlignment: .trailing)
        }
    }

    /// Brand / designer label — Figma `label/small` (12pt) across all card sizes.
    var designerFont: UIFont {
        DesignSystem.shared.font.body.small.uiFont
    }

    /// Product name — Figma `body/medium` (16pt) on PLP grid/list; small carousel keeps 12pt.
    var nameFont: UIFont {
        switch size {
        case .small:
            DesignSystem.shared.font.body.small.uiFont
        case .medium,
             .large: // swiftlint:disable:this indentation_width
            DesignSystem.shared.font.body.medium.uiFont
        }
    }

    /// Product name colour — Figma `#111111` on PLP grid/list; small carousel keeps its muted tone.
    var nameColor: Color {
        switch size {
        case .small:
            Primitives.Colours.neutrals500
        case .medium,
             .large: // swiftlint:disable:this indentation_width
            Primitives.Colours.neutrals800
        }
    }

    /// Product name line height — Figma `body/medium` is 24pt on PLP grid/list; small carousel keeps the font's natural leading.
    var nameLineHeight: CGFloat {
        switch size {
        case .small:
            DesignSystem.shared.font.body.small.uiFont.lineHeight
        case .medium,
             .large: // swiftlint:disable:this indentation_width
            Primitives.Spacing.spacing24
        }
    }

    var smallTextFont: UIFont {
        // All sizes map to the same token; no per-size distinction after token migration.
        DesignSystem.shared.font.body.small.uiFont
    }
    // swiftlint:enable vertical_whitespace_between_cases
}

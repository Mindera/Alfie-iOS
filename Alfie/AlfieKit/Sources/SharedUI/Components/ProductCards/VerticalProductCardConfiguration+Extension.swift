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
        switch size {
        case .small:
            Spacing.space100
        case .medium:
            Spacing.space150
        case .large:
            Spacing.space200
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

    var textFont: UIFont {
        switch size {
        case .small,
             .medium: // swiftlint:disable:this indentation_width
            ThemeProvider.shared.font.small.normal
        case .large:
            ThemeProvider.shared.font.paragraph.normal
        }
    }

    var smallTextFont: UIFont {
        switch size {
        case .small,
             .medium: // swiftlint:disable:this indentation_width
            ThemeProvider.shared.font.tiny.normal
        case .large:
            ThemeProvider.shared.font.small.normal
        }
    }
    // swiftlint:enable vertical_whitespace_between_cases
}

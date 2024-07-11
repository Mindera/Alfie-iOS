import Models
import SwiftUI

public enum PriceType: Hashable {
    case `default`(price: String)
    case sale(fullPrice: String, finalPrice: String)
    case range(lowerBound: String, upperBound: String, separator: String)
}

extension PriceType {
    init(from product: Product) {
        if let range = product.priceRange {
            if let high = range.high {
                self = .range(lowerBound: range.low.amountFormatted,
                              upperBound: high.amountFormatted,
                              separator: "-")
            } else {
                self = .default(price: range.low.amountFormatted)
            }
        } else {
            if let salePreviousPrice = product.defaultVariant.price.was {
                self = .sale(fullPrice: salePreviousPrice.amountFormatted,
                             finalPrice: product.defaultVariant.price.amount.amountFormatted)
            } else {
                self = .default(price: product.defaultVariant.price.amount.amountFormatted)
            }
        }
    }
}

public extension PriceType {
    static func formattedDefault(_ defaultPrice: Double, currencyCode: String) -> PriceType {
        .default(price: defaultPrice.formatted(.currency(code: currencyCode)))
    }

    static func formattedSale(fullPrice: Double, finalPrice: Double, currencyCode: String) -> PriceType {
        .sale(fullPrice: fullPrice.formatted(.currency(code: currencyCode)),
              finalPrice: finalPrice.formatted(.currency(code: currencyCode)))
    }

    static func formattedRange(lowerBound: Double, upperBound: Double, currencyCode: String, separator: String = "-") -> PriceType {
        .range(lowerBound: lowerBound.formatted(.currency(code: currencyCode)),
               upperBound: upperBound.formatted(.currency(code: currencyCode)),
               separator: separator)
    }
}

public enum PriceDistribution: String {
    case vertical
    case horizontal
}

public enum PriceSize: String {
    case small
    case large
}

public struct PriceConfiguration {
    public let preferredDistribution: PriceDistribution
    public let size: PriceSize
    public let textAlignment: TextAlignment

    public init(preferredDistribution: PriceDistribution,
                size: PriceSize,
                textAlignment: TextAlignment = .trailing) {
        self.preferredDistribution = preferredDistribution
        self.size = size
        self.textAlignment = textAlignment
    }
}

public struct PriceComponentView: View {
    private let type: PriceType
    private let configuration: PriceConfiguration

    private enum Constants {
        static let verticalRangeSeparatorHeight: CGFloat = 4

        static func defaultTextSize(for size: PriceSize) -> CGFloat {
            switch size {
                case .small: 14
                case .large: 16
            }
        }
        static func saleFullPriceTextSize(for size: PriceSize) -> CGFloat {
            switch size {
                case .small: 12
                case .large: 14
            }
        }
        static func saleFinalPriceTextSize(for size: PriceSize) -> CGFloat {
            switch size {
                case .small: 14
                case .large: 16
            }
        }
        static func verticalRangeTextSize(for size: PriceSize) -> CGFloat {
            switch size {
                case .small: 12
                case .large: 14
            }
        }
        static func horizontalRangeTextSize(for size: PriceSize) -> CGFloat {
            switch size {
                case .small: 14
                case .large: 16
            }
        }
    }

    public init(type: PriceType,
                configuration: PriceConfiguration) {
        self.type = type
        self.configuration = configuration
    }

    public var body: some View {
        VStack {
            switch type {
                case let .default(price):
                    defaultPrice(price, textSize: Constants.defaultTextSize(for: configuration.size))
                        .accessibilityIdentifier(AccessibilityId.priceFull)
                case let .sale(fullPrice, finalPrice):
                    salePrice(fullPrice: fullPrice, finalPrice: finalPrice)
                case let .range(lowerBound, upperBound, separator):
                    rangePrice(lowerBound: lowerBound, upperBound: upperBound, separator: separator)
            }
        }
    }

    // MARK: - Default

    private func defaultPrice(_ price: String, textSize: CGFloat) -> some View {
        priceText(price, textSize: textSize)
            .foregroundStyle(Colors.primary.mono900)
    }

    // MARK: - Sale

    @ViewBuilder
    private func salePrice(fullPrice: String, finalPrice: String) -> some View {
        switch configuration.preferredDistribution {
            case .vertical:
                verticalSalePrice(fullPrice: fullPrice, finalPrice: finalPrice)
            case .horizontal:
                ViewThatFits(in: .horizontal) {
                    horizontalSalePrice(fullPrice: fullPrice, finalPrice: finalPrice)
                    verticalSalePrice(fullPrice: fullPrice, finalPrice: finalPrice)
                }
        }
    }

    private func verticalSalePrice(fullPrice: String, finalPrice: String) -> some View {
        VStack(alignment: configuration.textAlignment.horizontalAlignment, spacing: Spacing.space050) {
            saleFullPrice(fullPrice)
            saleFinalPrice(finalPrice)
        }
    }

    private func horizontalSalePrice(fullPrice: String, finalPrice: String) -> some View {
        HStack(spacing: Spacing.space050) {
            saleFinalPrice(finalPrice)
            saleFullPrice(fullPrice)
        }
    }

    private func saleFullPrice(_ price: String) -> some View {
        Text(price)
            .font(Font(theme.font.paragraph.normal.withSize(Constants.saleFullPriceTextSize(for: configuration.size))))
            .foregroundStyle(Colors.primary.mono600)
            .strikethrough()
            .accessibilityIdentifier(AccessibilityId.priceHigher)
    }

    private func saleFinalPrice(_ price: String) -> some View {
        priceText(price, textSize: Constants.saleFinalPriceTextSize(for: configuration.size))
            .foregroundStyle(Colors.secondary.red800)
            .accessibilityIdentifier(AccessibilityId.priceLower)
    }

    // MARK: - Range

    @ViewBuilder
    private func rangePrice(lowerBound: String, upperBound: String, separator: String) -> some View {
        switch configuration.preferredDistribution {
            case .vertical:
                verticalRangePrice(lowerBound: lowerBound, upperBound: upperBound, separator: separator)
            case .horizontal:
                ViewThatFits(in: .horizontal) {
                    horizontalRangePrice(lowerBound: lowerBound, upperBound: upperBound, separator: separator)
                    verticalRangePrice(lowerBound: lowerBound, upperBound: upperBound, separator: separator)
                }
        }
    }

    private func verticalRangePrice(lowerBound: String, upperBound: String, separator: String) -> some View {
        VStack(alignment: configuration.textAlignment.horizontalAlignment, spacing: Spacing.space0) {
            defaultPrice(lowerBound, textSize: Constants.verticalRangeTextSize(for: configuration.size))
                .accessibilityIdentifier(AccessibilityId.priceLower)
            defaultPrice(separator, textSize: Constants.verticalRangeTextSize(for: configuration.size))
                .frame(height: Constants.verticalRangeSeparatorHeight)
            defaultPrice(upperBound, textSize: Constants.verticalRangeTextSize(for: configuration.size))
                .accessibilityIdentifier(AccessibilityId.priceHigher)
        }
    }

    private func horizontalRangePrice(lowerBound: String, upperBound: String, separator: String) -> some View {
        HStack(spacing: Spacing.space050) {
            defaultPrice(lowerBound, textSize: Constants.horizontalRangeTextSize(for: configuration.size))
                .accessibilityIdentifier(AccessibilityId.priceLower)
            defaultPrice(separator, textSize: Constants.horizontalRangeTextSize(for: configuration.size))
            defaultPrice(upperBound, textSize: Constants.horizontalRangeTextSize(for: configuration.size))
                .accessibilityIdentifier(AccessibilityId.priceHigher)
        }
    }

    private func priceText(_ price: String, textSize: CGFloat) -> Text {
        Text(price)
            .font(Font(theme.font.paragraph.normal.withSize(textSize)))
            .fontWeight(.semibold)
    }
}

private extension TextAlignment {
    var horizontalAlignment: HorizontalAlignment {
        switch self {
            case .leading: .leading
            case .center: .center
            case .trailing: .trailing
        }
    }
}

private enum AccessibilityId {
    static let priceFull = "product-price-full"
    static let priceLower = "product-price-lower"
    static let priceHigher = "product-price-higher"
}

#Preview {
    VStack {
        PriceComponentView(type: .default(price: "50€"),
                           configuration: .init(preferredDistribution: .horizontal,
                                                size: .small))

        PriceComponentView(type: .sale(fullPrice: "100€", finalPrice: "50€"),
                           configuration: .init(preferredDistribution: .horizontal,
                                                size: .small))

        PriceComponentView(type: .range(lowerBound: "50€", upperBound: "100€", separator: "-"),
                           configuration: .init(preferredDistribution: .horizontal,
                                                size: .small))
    }
}

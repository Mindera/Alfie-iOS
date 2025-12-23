import Model
import SharedUI
import SwiftUI

struct PriceComponentDemoView: View {
    private enum PriceTypeNamed: String, CaseIterable {
        case `default` = "Default"
        case sale = "Sale"
        case range = "Range"
    }

    @State private var currentPriceType: PriceType = .formattedDefault(
        Self.lowerPrice, currencyCode: Self.australianDollar
    )
    @State private var priceType: PriceTypeNamed = .default
    @State private var priceDistribution: PriceDistribution = .vertical
    @State private var priceSize: PriceSize = .large
    @State private var textAlignment: TextAlignment = .trailing
    @State private var currencyCode: String = Self.australianDollar
    private let priceTypes = PriceTypeNamed.allCases
    private let priceDistributions: [PriceDistribution] = [.vertical, .horizontal]
    private let priceSizes: [PriceSize] = [.small, .large]
    private let textAlignments = TextAlignment.allCases
    private let currencyCodes = Locale.commonISOCurrencyCodes
    private var isPriceDistributionAvailable: Bool {
        priceType != .default
    }
    private var isTextAlignmentAvailable: Bool {
        priceType != .default && priceDistribution == .vertical
    }
    private static let lowerPrice: Double = 59
    private static let higherPrice: Double = 719
    private static let australianDollar = "AUD"

    var body: some View {
        VStack {
            VStack {
                let formattedPriceType: PriceType = {
                    switch priceType {
                    case .default:
                        return .formattedDefault(Self.lowerPrice, currencyCode: currencyCode)

                    case .sale:
                        return .formattedSale(
                            fullPrice: Self.higherPrice,
                            finalPrice: Self.lowerPrice,
                            currencyCode: currencyCode
                        )

                    case .range:
                        return .formattedRange(
                            lowerBound: Self.lowerPrice,
                            upperBound: Self.higherPrice,
                            currencyCode: currencyCode
                        )
                    }
                }()

                PriceComponentView(
                    type: formattedPriceType,
                    configuration: .init(
                        preferredDistribution: priceDistribution,
                        size: priceSize,
                        textAlignment: textAlignment
                    )
                )
            }
            .frame(height: 60)
            .padding(.vertical, Spacing.space400)

            DemoHelper.demoSectionHeader(title: "Options")
            priceTypeOption
            priceSizeOption
            priceLayoutOption
                .disabled(!isPriceDistributionAvailable)
            priceAlignmentOption
                .disabled(!isTextAlignmentAvailable)
            currencyOption
        }
        .padding(.horizontal, Spacing.space200)
    }

    private var priceSizeOption: some View {
        HStack {
            Text.build(theme.font.small.bold("Size"))
            Spacer()
            Menu {
                Picker(selection: $priceSize) {
                    ForEach(priceSizes, id: \.self) { priceSize in
                        Text(priceSize.title)
                    }
                } label: {
                }
            } label: {
                Text.build(theme.font.small.normal(priceSize.title))
                    .tint(Colors.secondary.blue500)
            }
        }
        .padding(.top, Spacing.space200)
    }

    private var priceTypeOption: some View {
        HStack {
            Text.build(theme.font.small.bold("Type"))
            Spacer()
            Menu {
                Picker(selection: $priceType) {
                    ForEach(priceTypes, id: \.self) { priceType in
                        Text(priceType.rawValue)
                    }
                } label: {
                }
            } label: {
                Text.build(theme.font.small.normal(priceType.rawValue))
                    .tint(Colors.secondary.blue500)
            }
        }
        .padding(.top, Spacing.space200)
    }

    private var priceLayoutOption: some View {
        HStack {
            Text.build(theme.font.small.bold("Layout"))
            Spacer()
            Menu {
                Picker(selection: $priceDistribution) {
                    ForEach(priceDistributions, id: \.self) { distribution in
                        Text(distribution.title)
                    }
                } label: {
                }
            } label: {
                Text.build(theme.font.small.normal(priceDistribution.title))
                    .tint(Colors.secondary.blue500)
            }
        }
        .padding(.top, Spacing.space200)
    }

    private var priceAlignmentOption: some View {
        HStack {
            Text.build(theme.font.small.bold("Alignment"))
            Spacer()
            Menu {
                Picker(selection: $textAlignment) {
                    ForEach(textAlignments, id: \.self) { alignment in
                        Text(alignment.title)
                    }
                } label: {
                }
            } label: {
                Text.build(theme.font.small.normal(textAlignment.title))
                    .tint(Colors.secondary.blue500)
            }
        }
        .padding(.top, Spacing.space200)
    }

    private var currencyOption: some View {
        HStack {
            Text.build(theme.font.small.bold("Currency"))
            Spacer()
            Menu {
                Picker(selection: $currencyCode) {
                    ForEach(currencyCodes, id: \.self) { code in
                        Text(code)
                    }
                } label: {
                }
            } label: {
                Text.build(theme.font.small.normal(currencyCode))
                    .tint(Colors.secondary.blue500)
            }
        }
        .padding(.top, Spacing.space200)
    }
}

// MARK: - Helpers

private extension PriceDistribution {
    var title: String {
        rawValue.capitalized
    }
}

private extension PriceSize {
    var title: String {
        rawValue.capitalized
    }
}

private extension TextAlignment {
    var title: String {
        switch self {
        case .leading:
            return "Leading"
        case .center:
            return "Center"
        case .trailing:
            return "Trailing"
        }
    }
}

#Preview {
    PriceComponentDemoView()
}

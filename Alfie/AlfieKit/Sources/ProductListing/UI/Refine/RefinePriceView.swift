import AccessibilityIdentifiers
import Model
import SharedUI
import SwiftUI

/// Price sub-screen. Reached only when the category has bounds to filter within, so the slider
/// always has a scale (see `ProductListingFilter.rows`).
struct RefinePriceView<ViewModel: RefineViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    let bounds: PriceFilterBounds

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.space300) {
            RangeSlider(
                configuration: .init(
                    bounds: bounds.range,
                    lowerValue: $viewModel.pendingMinPrice,
                    upperValue: $viewModel.pendingMaxPrice,
                    lowerLabel: L10n.Plp.Refine.Price.Min.label,
                    upperLabel: L10n.Plp.Refine.Price.Max.label,
                    valueDescription: { value in
                        CurrencyFormatter.string(amount: Decimal(value), currencyCode: bounds.currencyCode)
                    },
                    inputs: .init(
                        prefix: viewModel.currencySymbol,
                        isError: viewModel.isPriceRangeInvalid,
                        lowerAccessibilityIdentifier: AccessibilityID.ProductListing.refinePriceMinInput,
                        upperAccessibilityIdentifier: AccessibilityID.ProductListing.refinePriceMaxInput
                    )
                )
            )

            if viewModel.isPriceRangeInvalid {
                Text.build(theme.font.body.small(L10n.Plp.Refine.Price.InvalidRange.message))
                    .foregroundStyle(Theme.contentContentNegative)
                    .accessibilityIdentifier(AccessibilityID.ProductListing.refinePriceError)
            }

            Spacer()
        }
        .padding(.horizontal, theme.spacing.space200)
        .padding(.top, theme.spacing.space300)
    }
}

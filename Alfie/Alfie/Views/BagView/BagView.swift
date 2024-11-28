import Models
import StyleGuide
import SwiftUI
#if DEBUG
import Mocks
#endif

struct BagView<ViewModel: BagViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            ForEach(viewModel.products) { product in
                HorizontalProductCard(
                    image: product.media.first?.asImage?.url,
                    designer: product.brand.name,
                    name: product.name,
                    colorTitle: LocalizableGeneral.$color + ":",
                    color: product.colour?.name ?? "",
                    sizeTitle: LocalizableGeneral.$size + ":",
                    size: product.size == nil ? LocalizableGeneral.$oneSize : product.sizeText,
                    priceType: product.priceType
                )
                .listRowInsets(EdgeInsets())
            }
            .onDelete { offsets in
                for index in offsets.makeIterator() {
                    viewModel.didSelectDelete(for: viewModel.products[index])
                }
            }
            .listRowSeparator(.hidden)
            .padding(.horizontal, Spacing.space200)
        }
        .listStyle(.plain)
        .listRowSpacing(Spacing.space200)
        .padding(.vertical, Spacing.space200)
        .withToolbar(for: .tab(.bag))
        .onAppear {
            viewModel.viewDidAppear()
        }
    }
}

#if DEBUG
#Preview {
    BagView(viewModel: BagViewModel(dependencies: BagDependencyContainer(bagService: MockBagService())))
        .environmentObject(Coordinator())
}
#endif

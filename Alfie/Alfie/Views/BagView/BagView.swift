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
                    product: product,
                    colorTitle: LocalizableGeneral.$color + ":",
                    sizeTitle: LocalizableGeneral.$size + ":",
                    oneSizeTitle: LocalizableGeneral.$oneSize
                )
                .listRowInsets(EdgeInsets())
            }
            .onDelete { offsets in
                for index in offsets.makeIterator() {
                    viewModel.didSelectDelete(for: viewModel.products[index].id)
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

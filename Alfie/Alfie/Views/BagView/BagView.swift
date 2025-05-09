import Models
import StyleGuide
import SwiftUI
#if DEBUG
import Mocks
#endif

struct BagView<ViewModel: BagViewModelProtocol>: View {
    @EnvironmentObject var coordinador: Coordinator
    @StateObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            ForEach(viewModel.products) { product in
                Button(
                    action: { coordinador.openDetails(for: product) },
                    label: {
                        HorizontalProductCard(viewModel: viewModel.productCardViewModel(for: product))
                            .contentShape(Rectangle())
                    }
                )
                .buttonStyle(.plain)
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
    BagView(
        viewModel: MockBagViewModel(
            products: [
                .init(product: Product.fixture())
            ]
        )
    )
    .environmentObject(Coordinator())
}
#endif

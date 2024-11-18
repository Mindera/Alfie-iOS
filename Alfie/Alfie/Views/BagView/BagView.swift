import Models
import StyleGuide
import SwiftUI
#if DEBUG
import Mocks
#endif

struct BagView<ViewModel: BagViewModelProtocol>: View {
    #if DEBUG
    @EnvironmentObject var mockContent: MockContent
    #endif

    @StateObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
    #if DEBUG
        List {
            ForEach(mockContent.bagProducts) { product in
                HorizontalProductCard(
                    product: product,
                    colorTitle: LocalizableGeneral.$color + ":",
                    sizeTitle: LocalizableGeneral.$size + ":",
                    oneSizeTitle: LocalizableGeneral.$oneSize
                )
                .listRowInsets(EdgeInsets())
            }
            .onDelete { offsets in
                mockContent.bagProducts.remove(atOffsets: offsets)
            }
            .listRowSeparator(.hidden)
            .padding(.horizontal, Spacing.space200)
        }
        .listStyle(.plain)
        .listRowSpacing(Spacing.space200)
        .padding(.vertical, Spacing.space200)
        .withToolbar(for: .tab(.bag))
    #else
        if let webViewModel = viewModel.webViewModel() as? WebViewModel {
            WebView(viewModel: webViewModel)
                .withToolbar(for: .tab(.bag))
        }
    #endif
    }
}

#if DEBUG
#Preview {
    BagView(viewModel: BagViewModel(dependencies: MockBagDependencyContainer()))
        .environmentObject(Coordinator())
}
#endif

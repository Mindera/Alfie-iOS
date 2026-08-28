import Model
import SharedUI
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
            ForEach(lines) { line in
                Text(line.name ?? "")
                    .listRowSeparator(.hidden)
                    .padding(.horizontal, Primitives.Spacing.spacing16)
            }
        }
        .listStyle(.plain)
        .listRowSpacing(Primitives.Spacing.spacing16)
        .padding(.vertical, Primitives.Spacing.spacing16)
        .toolbarView(
            isWishlistEnabled: viewModel.isWishlistEnabled,
            openWishlistAction: viewModel.didTapWishlist,
            myAccountAction: viewModel.didTapMyAccount
        )
        .onAppear {
            viewModel.viewDidAppear()
        }
    }

    /// A shopper with no cart and a cart with no lines are the same empty bag to the view.
    private var lines: [CartLine] {
        (viewModel.state.value ?? nil)?.lines ?? []
    }
}

#if DEBUG
#Preview {
    BagView(viewModel: MockBagViewModel(state: .success(.fixture(lines: [.fixture()]))))
}
#endif

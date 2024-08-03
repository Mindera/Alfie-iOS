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
        if let webViewModel = viewModel.webViewModel() as? WebViewModel {
            WebView(viewModel: webViewModel)
                .withToolbar(for: .tab(.bag))
        }
    }
}

#if DEBUG
#Preview {
    BagView(viewModel: BagViewModel(dependencies: MockBagDependencyContainer()))
        .environmentObject(Coordinator())
}
#endif

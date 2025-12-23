import SwiftUI

public extension MyAccountRoute {
    @ViewBuilder
    func destination(
        accountViewModel: () -> some AccountViewModelProtocol,
        intentViewBuilder: @escaping (MyAccountIntent) -> AnyView
    ) -> some View {
        switch self {
        case .myAccount:
            AccountView(viewModel: accountViewModel())

        case .myAccountIntent(let itent):
            intentViewBuilder(itent)
        }
    }
}

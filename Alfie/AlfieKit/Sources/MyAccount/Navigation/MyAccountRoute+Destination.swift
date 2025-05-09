import SwiftUI

public extension MyAccountRoute {
    @ViewBuilder
    func destination(
        accountViewModel: () -> some AccountViewModelProtocol2,
        intentViewBuilder: @escaping (MyAccountIntent) -> AnyView
    ) -> some View {
        switch self {
        case .myAccount:
            AccountView2(viewModel: accountViewModel())

        case .myAccountIntent(let itent):
            intentViewBuilder(itent)
        }
    }
}

import SharedUI
import SwiftUI
//#if DEBUG
//import Mocks
//#endif

public struct AccountView2<ViewModel: AccountViewModelProtocol2>: View {
    @StateObject private var viewModel: ViewModel
//    @EnvironmentObject var coordinator: Coordinator

    public init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.space0) {
                ForEach(viewModel.sectionList, id: \.self) { section in
                    AccountSectionView2(
                        for: section,
                        hiddenDividerTop: section == viewModel.sectionList.first,
                        hiddenDividerBottom: section != viewModel.sectionList.last
                    )
                    .modifier(
                        TapHighlightableModifier(
                            action: { navigateToSection(section) },
                            accessibilityId: section.accessibilityId
                        )
                    )
                }
            }
        }
        .padding(.horizontal, Spacing.space200)
        .toolbarView()
    }

    private func navigateToSection(_ section: AccountSection2) {
        switch section {
        case .wishlist:
            viewModel.didTapWishlist()

        case .signIn:
            viewModel.didTapSignIn()

        case .signOut:
            viewModel.didTapSignOut()

        case .myAddressBook,
             .myDetails, // swiftlint:disable:this indentation_width
             .myOrders,
             .wallet:
            // TODO: Implement in a future ticket
            break
        }
    }
}

private enum AccessibilityId { // TODO: Move to a seperate model and see where we have more AccessibilityID's
    static let addressBookSection = "address-book-section"
    static let myDetailsSection = "my-details-section"
    static let myOrdersSection = "my-orders-section"
    static let signInSection = "sign-in-section"
    static let signOutSection = "sign-out-section"
    static let walletSection = "wallet-section"
    static let wishlistSection = "wishlist-section"
}

private extension AccountSection2 {
    var accessibilityId: String {
        // swiftlint:disable vertical_whitespace_between_cases
        switch self {
        case .myAddressBook:
            AccessibilityId.addressBookSection
        case .myDetails:
            AccessibilityId.myDetailsSection
        case .myOrders:
            AccessibilityId.myOrdersSection
        case .signIn:
            AccessibilityId.signInSection
        case .signOut:
            AccessibilityId.signOutSection
        case .wallet:
            AccessibilityId.walletSection
        case .wishlist:
            AccessibilityId.wishlistSection
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}

//#if DEBUG
//#Preview {
//    AccountView2(
//        viewModel: AccountViewModel2(
//            configurationService: MockConfigurationService(),
//            sessionService: MockSessionService()
//        )
//    )
//    .environmentObject(Coordinator())
//}
//#endif

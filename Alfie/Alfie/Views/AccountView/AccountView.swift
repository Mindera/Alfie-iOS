import StyleGuide
import SwiftUI

struct AccountView<ViewModel: AccountViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel
    @EnvironmentObject var coordinator: Coordinator

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.space0) {
                ForEach(viewModel.sectionList, id: \.self) { section in
                    AccountSectionView(
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
        .withToolbar(for: .account)
    }

    private func navigateToSection(_: AccountSection) {}
}

private enum AccessibilityId {
    static let myDetailsSection = "my-details-section"
    static let myOrdersSection = "my-orders-section"
    static let walletSection = "wallet-section"
    static let addressBookSection = "address-book-section"
    static let wishlistSection = "wishlist-section"
    static let signOutSection = "sign-out-section"
}

private extension AccountSection {
    var accessibilityId: String {
        // swiftlint:disable vertical_whitespace_between_cases
        switch self {
        case .myDetails:
            AccessibilityId.myDetailsSection
        case .myOrders:
            AccessibilityId.myOrdersSection
        case .wallet:
            AccessibilityId.walletSection
        case .myAddressBook:
            AccessibilityId.addressBookSection
        case .wishlist:
            AccessibilityId.wishlistSection
        case .signOut:
            AccessibilityId.signOutSection
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}

#Preview {
    AccountView(viewModel: AccountViewModel())
        .environmentObject(Coordinator())
}

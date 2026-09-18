import AccessibilityIdentifiers
import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif

public struct AccountView<ViewModel: AccountViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel

    public init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Primitives.Spacing.spacing24) {
                welcome

                VStack(spacing: Primitives.Spacing.spacing0) {
                    ForEach(viewModel.sectionList, id: \.self) { section in
                        row(for: section)
                    }
                }

                row(for: viewModel.sessionSection)
            }
            .padding(.horizontal, Primitives.Spacing.spacing16)
            .padding(.vertical, Primitives.Spacing.spacing8)
        }
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(
            isPresented: Binding(
                get: { viewModel.fullScreenCover != nil },
                set: { if !$0 { viewModel.fullScreenCover = nil } }
            )
        ) {
            viewModel.fullScreenCover
        }
    }

    private var welcome: some View {
        VStack(alignment: .leading, spacing: Primitives.Spacing.spacing0) {
            Text.build(theme.font.display.small(L10n.Account.greeting))
                .foregroundStyle(Theme.contentContentPrimary)
                .accessibilityIdentifier(AccessibilityID.Account.greetingLabel)

            Text.build(theme.font.label.small(L10n.Account.memberSince))
                .foregroundStyle(Theme.contentContentTerciary)
                .accessibilityIdentifier(AccessibilityID.Account.memberSinceLabel)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func row(for section: AccountSection) -> some View {
        AccountSectionView(for: section)
            .modifier(
                TapHighlightableModifier(
                    action: { navigateToSection(section) },
                    accessibilityId: section.accessibilityId
                )
            )
    }

    private func navigateToSection(_ section: AccountSection) {
        switch section {
        case .wishlist:
            viewModel.didTapWishlist()

        case .signIn:
            viewModel.didTapSignIn()

        case .signOut:
            viewModel.didTapSignOut()

        case .settings:
            viewModel.didTapSettings()

        case .myAddressBook,
             .orders, // swiftlint:disable:this indentation_width
             .personalInformation,
             .wallet:
            // TODO: Implement in a future ticket
            break
        }
    }
}

private extension AccountSection {
    var accessibilityId: String {
        // swiftlint:disable vertical_whitespace_between_cases
        switch self {
        case .personalInformation:
            AccessibilityID.Account.personalInformationSection
        case .orders:
            AccessibilityID.Account.ordersSection
        case .wishlist:
            AccessibilityID.Account.wishlistSection
        case .wallet:
            AccessibilityID.Account.walletSection
        case .myAddressBook:
            AccessibilityID.Account.addressBookSection
        case .settings:
            AccessibilityID.Account.settingsSection
        case .signIn:
            AccessibilityID.Account.signInSection
        case .signOut:
            AccessibilityID.Account.signOutSection
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}

#if DEBUG
#Preview {
    AccountView(
        viewModel: AccountViewModel(
            dependencies: .init(
                configurationService: MockConfigurationService(),
                sessionService: MockSessionService(),
                makeSettingsView: { _ in AnyView(EmptyView()) }
            )
        ) { _ in
        }
    )
}
#endif

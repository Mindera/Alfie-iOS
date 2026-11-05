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
            VStack(alignment: .leading, spacing: theme.sizing.spacingSpacingLg) {
                welcome

                VStack(spacing: theme.sizing.spacingSpacingNone) {
                    ForEach(viewModel.sectionList, id: \.self) { section in
                        row(for: section)
                    }
                }

                row(for: viewModel.sessionSection)
            }
            .padding(.horizontal, theme.sizing.spacingSpacingMd)
            .padding(.vertical, theme.sizing.spacingSpacingXs)
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
        VStack(alignment: .leading, spacing: theme.sizing.spacingSpacingNone) {
            Text.build(theme.font.display.small(L10n.Account.greeting))
                .foregroundStyle(theme.color.contentContentPrimary)
                .accessibilityIdentifier(AccessibilityID.Account.greetingLabel)

            Text.build(theme.font.label.small(L10n.Account.memberSince))
                .foregroundStyle(theme.color.contentContentTerciary)
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

        case .addressBook,
             .orders, // swiftlint:disable:this indentation_width
             .personalInformation,
             .wallet:
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
        case .addressBook:
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

import Combine
import Foundation
import Model
import SharedUI
import SwiftUI

public final class AccountViewModel: AccountViewModelProtocol {
    private let configurationService: ConfigurationServiceProtocol
    private let sessionService: SessionServiceProtocol
    private let makeSettingsView: (@escaping PresentCover) -> AnyView
    private let navigate: (MyAccountRoute) -> Void
    private var subscriptions: Set<AnyCancellable> = []
    @Published public private(set) var sectionList: [AccountSection] = []
    @Published public var fullScreenCover: AnyView?

    public init(
        dependencies: MyAccountDependencyContainer,
        navigate: @escaping (MyAccountRoute) -> Void
    ) {
        self.sessionService = dependencies.sessionService
        self.configurationService = dependencies.configurationService
        self.makeSettingsView = dependencies.makeSettingsView
        self.navigate = navigate

        setupBindings()
    }

    private func setupBindings() {
        Publishers.CombineLatest(
            configurationService.featureAvailabilityPublisher,
            sessionService.isUserSignedInPublisher
        )
        .sink { [weak self] featureAvailability, isUserSignedIn in
            guard let self else { return }
            sectionList = [
                .myDetails,
                .myOrders,
                .wallet,
                .myAddressBook,
                featureAvailability[.wishlist] != nil ? .wishlist : nil,
                .settings,
                isUserSignedIn ? .signOut : .signIn,
            ]
            .compactMap { $0 }
        }
        .store(in: &subscriptions)
    }

    public func didTapWishlist() {
        navigate(.myAccountIntent(.wishlist))
    }

    public func didTapSignIn() {
        sessionService.signInUser()
    }

    public func didTapSignOut() {
        sessionService.signOutUser()
    }

    public func didTapSettings() {
        fullScreenCover = makeSettingsView { [weak self] view in
            self?.fullScreenCover = view
        }
    }
}

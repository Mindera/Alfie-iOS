import Combine
import Foundation
import Model
import SharedUI

public final class AccountViewModel: AccountViewModelProtocol {
    private let configurationService: ConfigurationServiceProtocol
    private let sessionService: SessionServiceProtocol
    private let navigate: (MyAccountRoute) -> Void
    private var subscriptions: Set<AnyCancellable> = []
    @Published public private(set) var sectionList: [AccountSection] = []

    public init(
        configurationService: ConfigurationServiceProtocol,
        sessionService: SessionServiceProtocol,
        navigate: @escaping (MyAccountRoute) -> Void
    ) {
        self.configurationService = configurationService
        self.sessionService = sessionService
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
}

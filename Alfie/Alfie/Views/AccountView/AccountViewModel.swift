import Combine
import Foundation
import Models
import StyleGuide

// MARK: - AccountViewModelProtocol

protocol AccountViewModelProtocol: ObservableObject {
    var sectionList: [AccountSection] { get }

    func didTapSignIn()
    func didTapSignOut()
}

// MARK: - AccountViewModel

final class AccountViewModel: AccountViewModelProtocol {
    private let configurationService: ConfigurationServiceProtocol
    private let sessionService: SessionServiceProtocol
    private var subscriptions: Set<AnyCancellable> = []
    @Published private(set) var sectionList: [AccountSection] = []

    init(configurationService: ConfigurationServiceProtocol, sessionService: SessionServiceProtocol) {
        self.configurationService = configurationService
        self.sessionService = sessionService

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

    func didTapSignIn() {
        sessionService.signInUser()
    }

    func didTapSignOut() {
        sessionService.signOutUser()
    }
}

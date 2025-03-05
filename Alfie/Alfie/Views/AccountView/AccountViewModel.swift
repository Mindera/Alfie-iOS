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
    // MARK: Properties

    private let configurationService: ConfigurationServiceProtocol
    private let sessionService: SessionServiceProtocol
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: Lifecycle

    init(configurationService: ConfigurationServiceProtocol, sessionService: SessionServiceProtocol) {
        self.configurationService = configurationService
        self.sessionService = sessionService

        setupBindings()
    }

    private func setupBindings() {
        Publishers.CombineLatest(
            configurationService.featureAvailabilityPublisher,
            sessionService.isUserLoggedPublisher
        )
        .sink { [weak self] _, isUserLogged in
            guard let self else { return }
            sectionList = [
                .myDetails,
                .myOrders,
                .wallet,
                .myAddressBook,
                configurationService.isFeatureEnabled(.wishlist) ? .wishlist : nil,
                isUserLogged ? .signOut : .signIn,
            ]
            .compactMap { $0 }
        }
        .store(in: &subscriptions)
    }

    // MARK: AccountViewModelProtocol

    @Published private(set) var sectionList: [AccountSection] = []

    func didTapSignIn() {
        sessionService.loginUser()
    }

    func didTapSignOut() {
        sessionService.logoutUser()
    }
}

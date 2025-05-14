//import Combine
//@testable import Alfie
//
//final class MockTabCoordinator: TabCoordinatorProtocol {
//    var tabs: [TabScreen]
//    var activeTab: TabScreen
//    @Published var isReadyForNavigation = true
//    var navigationAvailability: AnyPublisher<Bool, Never> { $isReadyForNavigation.eraseToAnyPublisher() }
//
//    init(tabs: [TabScreen] = TabScreen.allCases, activeTab: TabScreen = .bag) {
//        self.tabs = tabs
//        self.activeTab = activeTab
//    }
//
//    var onNavigateToScreenCalled: ((Screen) -> Void)?
//    func navigate(to screen: Screen) {
//        onNavigateToScreenCalled?(screen)
//    }
//}

import Model
import SharedUI
import XCTest
@testable import Home
@testable import Mocks

final class HomeViewModelTests: XCTestCase {
    private var mockSessionService: MockSessionService!
    private var capturedRoute: HomeRoute?
    private var showSearchCalled = false
    private var sut: HomeViewModel!

    override func setUp() {
        super.setUp()
        mockSessionService = MockSessionService()
        capturedRoute = nil
        showSearchCalled = false
        sut = HomeViewModel(
            dependencies: HomeDependencyContainer(
                configurationService: MockConfigurationService(),
                apiEndpointService: MockApiEndpointService(),
                sessionService: mockSessionService
            ),
            navigate: { [weak self] route in self?.capturedRoute = route },
            showSearch: { [weak self] in self?.showSearchCalled = true }
        )
    }

    override func tearDown() {
        sut = nil
        mockSessionService = nil
        super.tearDown()
    }

    func test_HeroBanners_ReturnsPlaceholders() {
        let banners = sut.heroBanners
        XCTAssertEqual(banners.count, 3)
        XCTAssertEqual(banners.map(\.id), ["hero-1", "hero-2", "hero-3"])
        XCTAssertEqual(banners.map(\.imageName), ["hero-1", "hero-2", "hero-3"])
    }

    func test_WhenSignedOut_SignInButtonText_ReflectsSignedOutState() {
        XCTAssertEqual(sut.signInButtonText, L10n.Home.SignIn.Button.cta)
    }

    func test_WhenSignedIn_SignInButtonText_ReflectsSignedInState() {
        mockSessionService.signInUser()

        XCTAssertEqual(sut.signInButtonText, L10n.Home.SignOut.Button.cta)
    }

    func test_DidTapSearch_CallsShowSearch() {
        sut.didTapSearch()
        XCTAssertTrue(showSearchCalled)
    }

    func test_DidTapMyAccount_NavigatesToMyAccount() {
        sut.didTapMyAccount()
        XCTAssertEqual(capturedRoute, .myAccount(.myAccount))
    }
}

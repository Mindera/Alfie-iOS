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
        XCTAssertEqual(sut.heroBanners, HomeHeroBanner.placeholders)
        XCTAssertFalse(sut.heroBanners.isEmpty)
    }

    func test_WhenSignedOut_SignInButtonAndUsername_ReflectSignedOutState() {
        XCTAssertEqual(sut.signInButtonText, L10n.Home.SignIn.Button.cta)
        XCTAssertNil(sut.username)
        XCTAssertNil(sut.memberSince)
    }

    func test_WhenSignIn_SignInButtonAndUsername_ReflectSignedInState() {
        mockSessionService.signInUser()

        XCTAssertEqual(sut.signInButtonText, L10n.Home.SignOut.Button.cta)
        XCTAssertNotNil(sut.username)
        XCTAssertNotNil(sut.memberSince)
    }

    func test_DidTapSearch_CallsShowSearch() {
        sut.didTapSearch()
        XCTAssertTrue(showSearchCalled)
    }

    func test_DidTapMyAccount_NavigatesToMyAccount() {
        sut.didTapMyAccount()
        XCTAssertEqual(capturedRoute, .myAccount(.myAccount))
    }

    func test_HeroViews_ConstructWithPlaceholders() {
        _ = HomeHeroBannerView(banner: HomeHeroBanner.placeholders[0])
        _ = HomeHeroCarouselView(banners: HomeHeroBanner.placeholders)
    }
}

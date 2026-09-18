import Mocks
import SwiftUI
import XCTest
@testable import MyAccount

final class AccountViewModelTests: XCTestCase {
    private var mockConfigurationService: MockConfigurationService!
    private var mockSessionService: MockSessionService!
    private var capturedPresent: PresentCover?
    private var sut: AccountViewModel!

    override func setUp() {
        super.setUp()
        mockConfigurationService = MockConfigurationService()
        mockSessionService = MockSessionService()
        sut = AccountViewModel(
            dependencies: MyAccountDependencyContainer(
                configurationService: mockConfigurationService,
                sessionService: mockSessionService,
                makeSettingsView: { [weak self] present in
                    self?.capturedPresent = present
                    return AnyView(EmptyView())
                }
            ),
            navigate: { _ in }
        )
    }

    override func tearDown() {
        sut = nil
        mockSessionService = nil
        mockConfigurationService = nil
        capturedPresent = nil
        super.tearDown()
    }

    func test_SectionList_ContainsSettings() {
        XCTAssertTrue(sut.sectionList.contains(.settings))
    }

    func test_WhenSignedOut_SessionSection_IsSignIn() {
        XCTAssertEqual(sut.sessionSection, .signIn)
    }

    func test_WhenSignedIn_SessionSection_IsSignOut() {
        mockSessionService.signInUser()

        XCTAssertEqual(sut.sessionSection, .signOut)
    }

    /// Sign Out is its own group in the design, so it must not be repeated in the list above it.
    func test_SectionList_ExcludesTheSessionSection() {
        XCTAssertFalse(sut.sectionList.contains(.signIn))
        XCTAssertFalse(sut.sectionList.contains(.signOut))
    }

    func test_SectionList_FollowsTheDesignOrder() {
        XCTAssertEqual(
            sut.sectionList,
            [.personalInformation, .orders, .wallet, .myAddressBook, .settings]
        )
    }

    func test_WhenWishlistIsAvailable_ItSitsBetweenOrdersAndWallet() {
        mockConfigurationService.forcedFeatureAvailabilitySubject.send([.wishlist: true])

        XCTAssertEqual(
            sut.sectionList,
            [.personalInformation, .orders, .wishlist, .wallet, .myAddressBook, .settings]
        )
    }

    func test_DidTapSettings_PresentsFullScreenCover() {
        XCTAssertNil(sut.fullScreenCover)
        sut.didTapSettings()
        XCTAssertNotNil(sut.fullScreenCover)
    }

    func test_DidTapSettings_PresentNil_DismissesFullScreenCover() {
        sut.didTapSettings()
        XCTAssertNotNil(sut.fullScreenCover)

        capturedPresent?(nil)

        XCTAssertNil(sut.fullScreenCover)
    }
}

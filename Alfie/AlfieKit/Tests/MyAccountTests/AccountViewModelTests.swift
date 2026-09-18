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

    func test_section_list_contains_settings() {
        XCTAssertTrue(sut.sectionList.contains(.settings))
    }

    func test_session_section_is_sign_in_when_signed_out() {
        XCTAssertEqual(sut.sessionSection, .signIn)
    }

    func test_session_section_is_sign_out_when_signed_in() {
        mockSessionService.signInUser()

        XCTAssertEqual(sut.sessionSection, .signOut)
    }

    /// Sign Out is its own group in the design, so it must not be repeated in the list above it.
    func test_section_list_excludes_the_session_section() {
        XCTAssertFalse(sut.sectionList.contains(.signIn))
        XCTAssertFalse(sut.sectionList.contains(.signOut))
    }

    func test_section_list_follows_the_design_order() {
        XCTAssertEqual(
            sut.sectionList,
            [.personalInformation, .orders, .wallet, .myAddressBook, .settings]
        )
    }

    func test_wishlist_sits_between_orders_and_wallet_when_available() {
        mockConfigurationService.forcedFeatureAvailabilitySubject.send([.wishlist: true])

        XCTAssertEqual(
            sut.sectionList,
            [.personalInformation, .orders, .wishlist, .wallet, .myAddressBook, .settings]
        )
    }

    func test_did_tap_settings_presents_the_settings_full_screen_cover() {
        XCTAssertNil(sut.fullScreenCover)
        sut.didTapSettings()
        XCTAssertNotNil(sut.fullScreenCover)
    }

    func test_presenting_nil_dismisses_the_settings_full_screen_cover() {
        sut.didTapSettings()
        XCTAssertNotNil(sut.fullScreenCover)

        capturedPresent?(nil)

        XCTAssertNil(sut.fullScreenCover)
    }
}

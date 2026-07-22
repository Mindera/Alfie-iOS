import Mocks
import SwiftUI
import XCTest
@testable import MyAccount

final class AccountViewModelTests: XCTestCase {
    private var mockSessionService: MockSessionService!
    private var capturedPresent: PresentCover?
    private var sut: AccountViewModel!

    override func setUp() {
        super.setUp()
        mockSessionService = MockSessionService()
        sut = AccountViewModel(
            dependencies: MyAccountDependencyContainer(
                configurationService: MockConfigurationService(),
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
        capturedPresent = nil
        super.tearDown()
    }

    func test_SectionList_ContainsSettings() {
        XCTAssertTrue(sut.sectionList.contains(.settings))
    }

    func test_WhenSignedOut_SectionList_ContainsSignInNotSignOut() {
        XCTAssertTrue(sut.sectionList.contains(.signIn))
        XCTAssertFalse(sut.sectionList.contains(.signOut))
    }

    func test_WhenSignedIn_SectionList_ContainsSignOutNotSignIn() {
        mockSessionService.signInUser()

        XCTAssertTrue(sut.sectionList.contains(.signOut))
        XCTAssertFalse(sut.sectionList.contains(.signIn))
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

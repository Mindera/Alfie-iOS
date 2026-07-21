import Mocks
import XCTest
@testable import MyAccount

final class AccountViewModelTests: XCTestCase {
    private var sut: AccountViewModel!

    override func setUp() {
        super.setUp()
        sut = AccountViewModel(
            dependencies: MyAccountDependencyContainer(
                configurationService: MockConfigurationService(),
                sessionService: MockSessionService(),
                apiEndpointService: MockApiEndpointService()
            ),
            navigate: { _ in }
        )
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_SectionList_ContainsSettings() {
        XCTAssertTrue(sut.sectionList.contains(.settings))
    }

    func test_DidTapSettings_PresentsFullScreenCover() {
        XCTAssertNil(sut.fullScreenCover)
        sut.didTapSettings()
        XCTAssertNotNil(sut.fullScreenCover)
    }
}

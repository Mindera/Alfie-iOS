import TestUtils
import XCTest
import Mocks
import Models
@testable import Alfie

final class AppStartupServiceTests: XCTestCase {
    private var sut: AppStartupService!
    private var mockConfigurationService: MockConfigurationService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockConfigurationService = .init()
        sut = .init(AppStartupService(configurationService: mockConfigurationService))
    }

    override func tearDownWithError() throws {
        sut = nil
        mockConfigurationService = nil
        try super.tearDownWithError()
    }

    func test_initial_screen_is_loading() throws {
        XCTAssertEqual(sut.currentScreen, .loading)
    }

    func test_forceAppUpdateAvailable_currentScreen_appUpdateScreen() {
        waitUntil(publisher: sut.$currentScreen.eraseToAnyPublisher(), emitsValue: .forceUpdate, asyncOperation: {
            self.mockConfigurationService.isForceAppUpdateAvailable = true
        }, timeout: defaultTimeout)
    }

    func test_softAppUpdateAvailable_redirects_to_landing() {
        waitUntil(publisher: sut.$currentScreen.eraseToAnyPublisher(), emitsValue: .landing, asyncOperation: {
            self.mockConfigurationService.isSoftAppUpdateAvailable = true
        }, timeout: defaultTimeout)
    }

    func test_currentScreen_is_eventually_landing() throws {
        //TODO: for now landing is set with a timer, this should be updated when we have actual loading of resources
        waitUntil(publisher: sut.$currentScreen.eraseToAnyPublisher(), emitsValue: .landing, timeout: 3)
    }
}

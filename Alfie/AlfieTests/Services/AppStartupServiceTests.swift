import AlicerceLogging
import AppFeature
import TestUtils
import XCTest
import Mocks
import Model
@testable import Alfie

final class AppStartupServiceTests: XCTestCase {
    private var sut: AppFeatureViewModel!
    private var mockServiceProvider: MockServiceProvider!
    private var mockConfigurationService: MockConfigurationService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockConfigurationService = .init()
        mockServiceProvider = .init(configurationService: mockConfigurationService)
        sut = .init(
            AppFeatureViewModel(
                serviceProvider: mockServiceProvider,
                log: Log.DummyLogger(),
                startupCompletionDelay: 0
            )
        )
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
        XCTAssertEmitsValueEqualTo(
            from: sut.$currentScreen,
            expectedValue: .forceUpdate,
            afterTrigger: { self.mockConfigurationService.isForceAppUpdateAvailable = true }
        )
    }

    func test_softAppUpdateAvailable_redirects_to_landing() {
        XCTAssertEmitsValueEqualTo(
            from: sut.$currentScreen,
            expectedValue: .landing,
            afterTrigger: { self.mockConfigurationService.isSoftAppUpdateAvailable = true }
        )
    }

    func test_currentScreen_is_eventually_landing() throws {
        //TODO: for now landing is set with a timer, this should be updated when we have actual loading of resources
        XCTAssertEmitsValueEqualTo(from: sut.$currentScreen.drop(while: { $0 == .loading }), expectedValue: .landing)
    }
}

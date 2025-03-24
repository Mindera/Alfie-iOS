import TestUtils
import XCTest
import Mocks
import Models
@testable import Alfie

final class ApiEndpointServiceTests: XCTestCase {
    private static let userDefaultsSuiteName = "com.alfie.test.defaults"
    private static let userDefaultsKey = "com.alfie.test.api.endpoint"
    private var sut: ApiEndpointService!
    private var userDefaults: UserDefaults!
    private var mockAppDelegate: MockAppDelegate!

    override func setUpWithError() throws {
        try super.setUpWithError()
        userDefaults = UserDefaults.init(suiteName: Self.userDefaultsSuiteName)
        mockAppDelegate = MockAppDelegate()
        // Init the sut in every test individually
    }

    override func tearDownWithError() throws {
        sut = nil
        userDefaults.removePersistentDomain(forName: Self.userDefaultsSuiteName)
        userDefaults.removeSuite(named: Self.userDefaultsSuiteName)
        userDefaults = nil
        mockAppDelegate = nil
        try super.tearDownWithError()
    }

    func test_reads_current_endpoint_on_init() {
        ApiEndpointOption.allCases.prefix(upTo: ApiEndpointOption.allCases.count - 1).forEach { option in
            let url = ApiEndpointUrl.url(for: option)
            userDefaults.setValue(url, forKey: Self.userDefaultsKey)
            createSut()
            XCTAssertEqual(sut.currentApiEndpoint, option)
        }
    }

    func test_reads_current_custom_endpoint_on_init() {
        let urlString = "https://www.endpoint.com"
        userDefaults.setValue(urlString, forKey: Self.userDefaultsKey)
        createSut()
        XCTAssertEqual(sut.currentApiEndpoint, .custom(url: URL(string: urlString)))
    }

    func test_sets_default_endpoint_on_init_when_no_userdefaults_are_set() {
        createSut()
        XCTAssertEqual(sut.currentApiEndpoint, ApiEndpointOption.dev)
    }

    func test_returns_correct_endpoint_url_for_each_available_option() {
        createSut()

        ApiEndpointOption.allCases.forEach { option in
            let url = sut.apiEndpoint(for: option).absoluteString
            let expectedUrl = ApiEndpointUrl.url(for: option)
            XCTAssertEqual(url, expectedUrl)
        }
    }

    func test_saves_selected_endpoint_url_to_userdefaults() {
        createSut()
        let selectedOption = ApiEndpointOption.dev
        sut.updateApiEndpointAndReboot(selectedOption)
        let expectedUrl = ApiEndpointUrl.url(for: selectedOption)
        XCTAssertEqual(userDefaults.value(forKey: Self.userDefaultsKey) as? String, expectedUrl)
    }

    func test_can_save_an_empty_custom_url_to_userdefaults_using_default_placeholder() {
        createSut()
        sut.updateApiEndpointAndReboot(.custom(url: nil))
        let expectedUrl = ApiEndpointUrl.url(for: .custom(url: nil))
        XCTAssertEqual(userDefaults.value(forKey: Self.userDefaultsKey) as? String, expectedUrl)
    }

    func test_can_save_a_custom_url_to_userdefaults() {
        createSut()
        let urlString = "https://www.endpoint.com"
        sut.updateApiEndpointAndReboot(.custom(url: URL(string: urlString)!))
        XCTAssertEqual(userDefaults.value(forKey: Self.userDefaultsKey) as? String, urlString)
    }

    func test_calls_reboot_when_saving_selected_endpoint() {
        let expectation = expectation(description: "Wait for reboot call")
        mockAppDelegate.onRebootAppCalled = {
            expectation.fulfill()
        }

        createSut()
        sut.updateApiEndpointAndReboot(.dev)
        wait(for: [expectation])
    }

    // MARK: - Private

    private func createSut() {
        sut = .init(
            appDelegate: mockAppDelegate,
            userDefaults: userDefaults,
            userDefaultsKey: Self.userDefaultsKey,
            rebootDelay: .inverted
        )
    }
}

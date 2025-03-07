import XCTest
import Mocks
import Models
@testable import Alfie

final class EndpointSelectionViewModelTests: XCTestCase {
    private var sut: EndpointSelectionViewModel!
    private var mockEndpointService: MockApiEndpointService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockEndpointService = MockApiEndpointService()
        // Init the sut in every test individually
    }

    override func tearDownWithError() throws {
        sut = nil
        mockEndpointService = nil
        try super.tearDownWithError()
    }

    func test_reads_current_endpoint_on_init() {
        mockEndpointService.currentApiEndpoint = .preProd
        sut = .init(apiEndpointService: mockEndpointService)
        XCTAssertEqual(sut.selectedEndpointOption, .preProd)
    }

    func test_reads_custom_endpoint_url_on_init() throws {
        let urlString = "https://www.endpoint.com"
        let url = try XCTUnwrap(URL(string: urlString))
        mockEndpointService.currentApiEndpoint = .custom(url: url)
        sut = .init(apiEndpointService: mockEndpointService)
        XCTAssertEqual(sut.selectedEndpointOption, .custom(url: url))
        XCTAssertEqual(sut.customEndpointUrl, urlString)
    }

    func test_sets_default_custom_url_on_init_when_custom_option_is_not_selected() throws {
        let urlString = "https://www.endpoint.com"
        mockEndpointService.currentApiEndpoint = .preProd
        mockEndpointService.onApiEndpointForOptionCalled = { _ in
            URL(string: urlString)!
        }
        sut = .init(apiEndpointService: mockEndpointService)
        XCTAssertEqual(sut.customEndpointUrl, urlString)
    }

    func test_shows_url_error_when_saving_empty_url() {
        sut = .init(apiEndpointService: mockEndpointService)
        sut.selectedEndpointOption = .custom(url: nil)
        sut.customEndpointUrl = ""
        sut.didTapSave()
        XCTAssertTrue(sut.shouldShowUrlError)
    }

    func test_clears_url_error_when_dismissing() {
        sut = .init(apiEndpointService: mockEndpointService)
        sut.selectedEndpointOption = .custom(url: nil)
        sut.customEndpointUrl = ""
        sut.didTapSave()
        XCTAssertTrue(sut.shouldShowUrlError)
        sut.didDismissError()
        XCTAssertFalse(sut.shouldShowUrlError)
    }

    func test_shows_success_when_saving() {
        sut = .init(apiEndpointService: mockEndpointService)
        sut.selectedEndpointOption = .preProd
        sut.didTapSave()
        XCTAssertTrue(sut.shouldShowSuccess)
    }

    func test_input_is_disabled_when_saving() {
        sut = .init(apiEndpointService: mockEndpointService)
        sut.selectedEndpointOption = .preProd
        sut.didTapSave()
        XCTAssertTrue(sut.isInputDisabled)
    }

    func test_input_is_disabled_when_selected_option_is_not_custom() {
        sut = .init(apiEndpointService: mockEndpointService)
        sut.selectedEndpointOption = .preProd
        XCTAssertTrue(sut.isInputDisabled)
    }

    func test_input_is_enabled_when_selected_option_is_custom() {
        sut = .init(apiEndpointService: mockEndpointService)
        sut.selectedEndpointOption = .custom(url: nil)
        XCTAssertFalse(sut.isInputDisabled)
    }

    func test_save_button_is_disabled_when_saving() {
        sut = .init(apiEndpointService: mockEndpointService)
        sut.selectedEndpointOption = .preProd
        sut.didTapSave()
        XCTAssertTrue(sut.isSaveDisabled)
    }

    func test_save_button_is_disabled_when_current_option_equals_selected_option() {
        mockEndpointService.currentApiEndpoint = .preProd
        sut = .init(apiEndpointService: mockEndpointService)
        sut.selectedEndpointOption = .preProd
        XCTAssertTrue(sut.isSaveDisabled)
    }

    func test_save_button_is_disabled_when_current_custom_url_equals_entered_url() {
        let urlString = "https://www.endpoint.com"
        let url = URL(string: urlString)!
        mockEndpointService.currentApiEndpoint = .custom(url: url)
        sut = .init(apiEndpointService: mockEndpointService)
        sut.selectedEndpointOption = .custom(url: nil)
        sut.customEndpointUrl = urlString
        XCTAssertTrue(sut.isSaveDisabled)
    }

    func test_save_button_is_enabled_when_current_custom_url_is_different_from_entered_url() {
        let originalUrlString = "https://www.endpoint.com"
        let alternativeUrlString = "https://www.other-endpoint.com"
        let url = URL(string: originalUrlString)!
        mockEndpointService.currentApiEndpoint = .custom(url: url)
        sut = .init(apiEndpointService: mockEndpointService)
        sut.selectedEndpointOption = .custom(url: nil)
        sut.customEndpointUrl = alternativeUrlString
        XCTAssertFalse(sut.isSaveDisabled)
    }

    func test_save_button_is_enabled_when_current_custom_option_has_nil_url() {
        mockEndpointService.currentApiEndpoint = .custom(url: nil)
        sut = .init(apiEndpointService: mockEndpointService)
        sut.selectedEndpointOption = .custom(url: nil)
        XCTAssertFalse(sut.isSaveDisabled)
    }

    func test_reports_all_endpoint_options_as_available() {
        sut = .init(apiEndpointService: mockEndpointService)
        XCTAssertEqual(sut.availableEndpointOptions, ApiEndpointOption.allCases)
    }

    func test_reports_only_dev_and_custom_endpoint_options_as_selectable() {
        sut = .init(apiEndpointService: mockEndpointService)
        XCTAssertEqual(sut.disabledEndpointOptions, [.preProd, .prod])
    }

    func test_reports_no_endpoint_options_as_selectable_when_saving() {
        sut = .init(apiEndpointService: mockEndpointService)
        sut.selectedEndpointOption = .custom(url: nil)
        sut.customEndpointUrl = "https://www.endpoint.com"
        sut.didTapSave()
        XCTAssertEqual(sut.disabledEndpointOptions, ApiEndpointOption.allCases)
    }

    func test_does_nothing_when_no_option_is_selected_when_saving() {
        sut = .init(apiEndpointService: mockEndpointService)
        sut.selectedEndpointOption = nil
        sut.didTapSave()
        XCTAssertFalse(sut.shouldShowUrlError)
        XCTAssertFalse(sut.shouldShowSuccess)
    }

    func test_saves_selected_option_on_service() {
        let expectation = expectation(description: "Wait for service call")
        mockEndpointService.onUpdateApiEndpointAndRebootCalled = { option in
            XCTAssertEqual(option, .preProd)
            expectation.fulfill()
        }

        sut = .init(apiEndpointService: mockEndpointService)
        sut.selectedEndpointOption = .preProd
        sut.didTapSave()
        wait(for: [expectation], timeout: `default`)
    }

    func test_saves_selected_custom_option_with_url_on_service() {
        let urlString = "https://www.endpoint.com"
        let url = URL(string: urlString)!
        let expectation = expectation(description: "Wait for service call")
        mockEndpointService.onUpdateApiEndpointAndRebootCalled = { option in
            XCTAssertEqual(option, .custom(url: url))
            expectation.fulfill()
        }

        sut = .init(apiEndpointService: mockEndpointService)
        sut.selectedEndpointOption = .custom(url: nil)
        sut.customEndpointUrl = urlString
        sut.didTapSave()
        wait(for: [expectation], timeout: `default`)
    }
}

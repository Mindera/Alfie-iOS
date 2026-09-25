import DebugMenu
import Mocks
import Model
import TestUtils
import XCTest

final class EndpointSelectionViewModelTests: XCTestCase {
    private var sut: DebugMenu.EndpointSelectionViewModel!
    private var mockEndpointService: MockApiEndpointService!
    private var mockApiKeyService: MockBFFApiKeyService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockEndpointService = MockApiEndpointService()
        mockApiKeyService = MockBFFApiKeyService()
        // Init the sut in every test individually
    }

    override func tearDownWithError() throws {
        sut = nil
        mockEndpointService = nil
        mockApiKeyService = nil
        try super.tearDownWithError()
    }

    func test_reads_current_endpoint_on_init() {
        mockEndpointService.currentApiEndpoint = .preProd
        sut = makeSut()
        XCTAssertEqual(sut.selectedEndpointOption, .preProd)
    }

    func test_reads_custom_endpoint_url_on_init() throws {
        let urlString = "https://www.endpoint.com"
        let url = try XCTUnwrap(URL(string: urlString))
        mockEndpointService.currentApiEndpoint = .custom(url: url)
        sut = makeSut()
        XCTAssertEqual(sut.selectedEndpointOption, .custom(url: url))
        XCTAssertEqual(sut.customEndpointUrl, urlString)
    }

    func test_sets_default_custom_url_on_init_when_custom_option_is_not_selected() throws {
        let urlString = "https://www.endpoint.com"
        mockEndpointService.currentApiEndpoint = .preProd
        mockEndpointService.onApiEndpointForOptionCalled = { _ in
            URL(string: urlString)!
        }
        sut = makeSut()
        XCTAssertEqual(sut.customEndpointUrl, urlString)
    }

    func test_shows_url_error_when_saving_empty_url() {
        sut = makeSut()
        sut.selectedEndpointOption = .custom(url: nil)
        sut.customEndpointUrl = ""
        sut.didTapSave()
        XCTAssertTrue(sut.shouldShowUrlError)
    }

    func test_clears_url_error_when_dismissing() {
        sut = makeSut()
        sut.selectedEndpointOption = .custom(url: nil)
        sut.customEndpointUrl = ""
        sut.didTapSave()
        XCTAssertTrue(sut.shouldShowUrlError)
        sut.didDismissError()
        XCTAssertFalse(sut.shouldShowUrlError)
    }

    func test_shows_success_when_saving() {
        sut = makeSut()
        sut.selectedEndpointOption = .preProd
        sut.didTapSave()
        XCTAssertTrue(sut.shouldShowSuccess)
    }

    func test_input_is_disabled_when_saving() {
        sut = makeSut()
        sut.selectedEndpointOption = .preProd
        sut.didTapSave()
        XCTAssertTrue(sut.isInputDisabled)
    }

    func test_input_is_disabled_when_selected_option_is_not_custom() {
        sut = makeSut()
        sut.selectedEndpointOption = .preProd
        XCTAssertTrue(sut.isInputDisabled)
    }

    func test_input_is_enabled_when_selected_option_is_custom() {
        sut = makeSut()
        sut.selectedEndpointOption = .custom(url: nil)
        XCTAssertFalse(sut.isInputDisabled)
    }

    func test_save_button_is_disabled_when_saving() {
        sut = makeSut()
        sut.selectedEndpointOption = .preProd
        sut.didTapSave()
        XCTAssertTrue(sut.isSaveDisabled)
    }

    func test_save_button_is_disabled_when_current_option_equals_selected_option() {
        mockEndpointService.currentApiEndpoint = .preProd
        sut = makeSut()
        sut.selectedEndpointOption = .preProd
        XCTAssertTrue(sut.isSaveDisabled)
    }

    func test_save_button_is_disabled_when_current_custom_url_equals_entered_url() {
        let urlString = "https://www.endpoint.com"
        let url = URL(string: urlString)!
        mockEndpointService.currentApiEndpoint = .custom(url: url)
        sut = makeSut()
        sut.selectedEndpointOption = .custom(url: nil)
        sut.customEndpointUrl = urlString
        XCTAssertTrue(sut.isSaveDisabled)
    }

    func test_save_button_is_enabled_when_current_custom_url_is_different_from_entered_url() {
        let originalUrlString = "https://www.endpoint.com"
        let alternativeUrlString = "https://www.other-endpoint.com"
        let url = URL(string: originalUrlString)!
        mockEndpointService.currentApiEndpoint = .custom(url: url)
        sut = makeSut()
        sut.selectedEndpointOption = .custom(url: nil)
        sut.customEndpointUrl = alternativeUrlString
        XCTAssertFalse(sut.isSaveDisabled)
    }

    func test_save_button_is_enabled_when_current_custom_option_has_nil_url() {
        mockEndpointService.currentApiEndpoint = .custom(url: nil)
        sut = makeSut()
        sut.selectedEndpointOption = .custom(url: nil)
        XCTAssertFalse(sut.isSaveDisabled)
    }

    func test_reports_all_endpoint_options_as_available() {
        sut = makeSut()
        XCTAssertEqual(sut.availableEndpointOptions, ApiEndpointOption.allCases)
    }

    func test_reports_only_dev_and_custom_endpoint_options_as_selectable() {
        sut = makeSut()
        XCTAssertEqual(sut.disabledEndpointOptions, [.preProd, .prod])
    }

    func test_reports_no_endpoint_options_as_selectable_when_saving() {
        sut = makeSut()
        sut.selectedEndpointOption = .custom(url: nil)
        sut.customEndpointUrl = "https://www.endpoint.com"
        sut.didTapSave()
        XCTAssertEqual(sut.disabledEndpointOptions, ApiEndpointOption.allCases)
    }

    func test_does_nothing_when_no_option_is_selected_when_saving() {
        sut = makeSut()
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

        sut = makeSut()
        sut.selectedEndpointOption = .preProd
        sut.didTapSave()
        wait(for: [expectation], timeout: .default)
    }

    func test_saves_selected_custom_option_with_url_on_service() {
        let urlString = "https://www.endpoint.com"
        let url = URL(string: urlString)!
        let expectation = expectation(description: "Wait for service call")
        mockEndpointService.onUpdateApiEndpointAndRebootCalled = { option in
            XCTAssertEqual(option, .custom(url: url))
            expectation.fulfill()
        }

        sut = makeSut()
        sut.selectedEndpointOption = .custom(url: nil)
        sut.customEndpointUrl = urlString
        sut.didTapSave()
        wait(for: [expectation], timeout: .default)
    }

    func test_reads_current_api_key_on_init() {
        mockApiKeyService.currentApiKey = "abc-123"

        sut = makeSut()

        XCTAssertEqual(sut.bffApiKey, "abc-123")
    }

    func test_saves_api_key_on_service() {
        sut = makeSut()
        sut.bffApiKey = "abc-123"

        sut.didTapSave()

        XCTAssertEqual(mockApiKeyService.currentApiKey, "abc-123")
    }

    /// The key is read per request, so changing only the key must not reboot the app out from under
    /// whatever the tester was looking at.
    func test_saving_only_the_api_key_does_not_reboot() {
        let reboot = expectation(description: "The app is not rebooted")
        reboot.isInverted = true
        mockEndpointService.onUpdateApiEndpointAndRebootCalled = { _ in reboot.fulfill() }
        sut = makeSut()
        sut.bffApiKey = "abc-123"

        sut.didTapSave()

        wait(for: [reboot], timeout: .inverted)
        XCTAssertTrue(sut.shouldShowSuccess)
        XCTAssertFalse(sut.willReboot)
    }

    func test_saving_an_endpoint_change_reports_a_pending_reboot() {
        sut = makeSut()
        sut.selectedEndpointOption = .preProd

        sut.didTapSave()

        XCTAssertTrue(sut.willReboot)
    }

    func test_save_button_is_enabled_when_only_the_api_key_changed() {
        sut = makeSut()

        sut.bffApiKey = "abc-123"

        XCTAssertFalse(sut.isSaveDisabled)
    }

    /// Whitespace-only edits are what the key store discards, so offering Save for them would
    /// promise a change that never happens.
    func test_save_button_stays_disabled_when_the_api_key_edit_is_only_whitespace() {
        sut = makeSut()

        sut.bffApiKey = "   "

        XCTAssertTrue(sut.isSaveDisabled)
    }

    /// An invalid URL aborts the whole save, so the key must not be written either — otherwise the
    /// error snackbar would be lying about what was persisted.
    func test_an_invalid_custom_url_saves_no_api_key() {
        sut = makeSut()
        sut.selectedEndpointOption = .custom(url: nil)
        sut.customEndpointUrl = ""
        sut.bffApiKey = "abc-123"

        sut.didTapSave()

        XCTAssertTrue(sut.shouldShowUrlError)
        XCTAssertNil(mockApiKeyService.currentApiKey)
    }

    private func makeSut() -> DebugMenu.EndpointSelectionViewModel {
        .init(
            apiEndpointService: mockEndpointService,
            apiKeyService: mockApiKeyService,
            closeEndpointSelection: {}
        )
    }
}

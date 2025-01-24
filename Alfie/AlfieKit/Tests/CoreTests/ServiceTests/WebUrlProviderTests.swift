import AlicerceLogging
@testable import Core
import Models
import XCTest

final class WebUrlProviderTests: XCTestCase {
    private struct MockURL: WebURLEndpoint {
        var path: String = "path"
        var parameters: [String : String]? = nil
    }

    private var sut: WebURLProvider!
    private var mockUrl: MockURL!
    private var log: Logger!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockUrl = .init()
        log = Log.DummyLogger()
        sut = WebURLProvider(scheme: "https", host: "www.host.au", log: log)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockUrl = nil
        log = nil
        try super.tearDownWithError()
    }

    func test_secure_web_scheme_builds_url() {
        sut = WebURLProvider(scheme: "https", host: "www.host.au", log: log)
        let url = sut.url(for: mockUrl)
        XCTAssertEqual(url?.absoluteString, "https://www.host.au/path")
    }

    func test_unsecure_web_scheme_builds_url() {
        sut = WebURLProvider(scheme: "http", host: "www.host.au", log: log)
        let url = sut.url(for: mockUrl)
        XCTAssertEqual(url?.absoluteString, "http://www.host.au/path")
    }

    func test_invalid_web_scheme_no_url() {
        sut = WebURLProvider(scheme: "alfie", host: "www.host.au", log: log)
        XCTAssertNil(sut.url(for: mockUrl))
    }

    func test_path_with_extra_prefix_slash_builds_url() {
        let url = sut.url(for: MockURL(path: "/path"))
        XCTAssertEqual(url?.absoluteString, "https://www.host.au/path")
    }

    func test_empty_parameters_builds_url() {
        mockUrl.parameters = [:]
        let url = sut.url(for: mockUrl)
        XCTAssertEqual(url?.absoluteString, "https://www.host.au/path")
    }

    func test_single_parameter_builds_url_with_query_item() {
        mockUrl.parameters = ["key": "value"]
        let url = sut.url(for: mockUrl)
        XCTAssertEqual(url?.absoluteString, "https://www.host.au/path?key=value")
    }

    func test_multiple_parameters_builds_url_with_query_items_sorted() {
        mockUrl.parameters = [
            "key2": "value2",
            "key1": "value1",
        ]
        let url = sut.url(for: mockUrl)
        XCTAssertEqual(url?.absoluteString, "https://www.host.au/path?key1=value1&key2=value2")
    }
}

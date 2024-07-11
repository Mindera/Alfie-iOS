import Mocks
import Models
import XCTest
@testable import Alfie

final class BagViewModelTests: XCTestCase {
    private var sut: BagViewModel!
    private var mockWebViewConfigurationService: MockWebViewConfigurationService!
    private var mockDependencies: MockBagDependencyContainer!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockWebViewConfigurationService = MockWebViewConfigurationService()
        mockDependencies = MockBagDependencyContainer(webViewConfigurationService: mockWebViewConfigurationService)
        sut = .init(dependencies: mockDependencies)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockDependencies = nil
        mockWebViewConfigurationService = nil
        try super.tearDownWithError()
    }

    func test_returns_webviewmodel_with_correct_url() throws {
        let url = URL(string: "http://some.url")!
        let expectation = expectation(description: "Wait for service call")
        mockWebViewConfigurationService.onUrlForFeatureCalled = { feature in
            XCTAssertEqual(feature, .bag)
            expectation.fulfill()
            return url
        }

        let viewModel = try XCTUnwrap(sut.webViewModel() as? WebViewModel)
        
        _ = captureEvent(fromPublisher: viewModel.$state.drop(while: { !$0.isReady }).eraseToAnyPublisher(), afterTrigger: {
            viewModel.viewDidAppear()
        })

        XCTAssertEqual(viewModel.state.url?.absoluteString, url.absoluteString)
    }
}

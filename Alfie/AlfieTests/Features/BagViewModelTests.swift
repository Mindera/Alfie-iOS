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
}

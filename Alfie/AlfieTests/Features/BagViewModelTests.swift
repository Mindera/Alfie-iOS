import Mocks
import Models
import XCTest
@testable import Alfie

final class BagViewModelTests: XCTestCase {
    private var sut: BagViewModel!
    private var mockWebViewConfigurationService: MockWebViewConfigurationService!
    private var mockDependencies: BagDependencyContainerProtocol!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockWebViewConfigurationService = MockWebViewConfigurationService()
        mockDependencies = BagDependencyContainer(bagService: MockBagService())
        sut = .init(dependencies: mockDependencies)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockDependencies = nil
        mockWebViewConfigurationService = nil
        try super.tearDownWithError()
    }
}

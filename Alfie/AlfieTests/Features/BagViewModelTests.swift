import Mocks
import Model
import XCTest
@testable import Alfie
@testable import Bag

final class BagViewModelTests: XCTestCase {
    private var sut: BagViewModel!
    private var mockDependencies: BagDependencyContainer!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockDependencies = BagDependencyContainer(
            bagService: MockBagService(),
            configurationService: MockConfigurationService(),
            analytics: MockAnalyticsTracker().eraseToAnyAnalyticsTracker()
        )
        sut = .init(dependencies: mockDependencies) { _ in }
    }

    override func tearDownWithError() throws {
        sut = nil
        mockDependencies = nil
        try super.tearDownWithError()
    }
}

import Models
import Core
import XCTest
@testable import Alfie

final class ProductListingStyleProviderTests: XCTestCase {
    private static let userDefaultsSuiteName = "com.alfie.test.defaults"
    
    private var sut: ProductListingStyleProvider!
    private var userDefaults: UserDefaults!

    override func setUpWithError() throws {
        try super.setUpWithError()
        userDefaults = UserDefaults.init(suiteName: Self.userDefaultsSuiteName)
    }

    override func tearDownWithError() throws {
        sut = nil
        userDefaults.removeSuite(named: Self.userDefaultsSuiteName)
        userDefaults = nil
        try super.tearDownWithError()
    }
    
    func test_defaultValuesIsGrid() {
        sut = ProductListingStyleProvider(userDefaults: userDefaults)
        XCTAssertEqual(sut.style, .grid)
    }
    
    func test_itSavesCorrectly() {
        sut = ProductListingStyleProvider(userDefaults: userDefaults)
        XCTAssertEqual(sut.style, .grid)
        sut.set(.list)
        sut = ProductListingStyleProvider(userDefaults: userDefaults)
        XCTAssertEqual(sut.style, .list)
    }
}

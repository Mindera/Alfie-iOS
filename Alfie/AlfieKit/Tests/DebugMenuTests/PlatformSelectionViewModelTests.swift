import DebugMenu
import Model
import XCTest

final class PlatformSelectionViewModelTests: XCTestCase {
    private var savedOverride: String?

    override func setUp() {
        super.setUp()
        savedOverride = UserDefaults.standard.string(forKey: BFFPlatformDebugStore.userDefaultsKey)
        UserDefaults.standard.removeObject(forKey: BFFPlatformDebugStore.userDefaultsKey)
    }

    override func tearDown() {
        if let savedOverride {
            UserDefaults.standard.set(savedOverride, forKey: BFFPlatformDebugStore.userDefaultsKey)
        } else {
            UserDefaults.standard.removeObject(forKey: BFFPlatformDebugStore.userDefaultsKey)
        }
        super.tearDown()
    }

    func test_init_reflects_stored_platform() {
        BFFPlatformDebugStore.selected = .bigCommerce
        let sut = PlatformSelectionViewModel()
        XCTAssertEqual(sut.selectedPlatform, .bigCommerce)
    }

    func test_init_does_not_overwrite_stored_value() {
        BFFPlatformDebugStore.selected = .bigCommerce
        _ = PlatformSelectionViewModel()
        XCTAssertEqual(BFFPlatformDebugStore.selected, .bigCommerce)
    }

    func test_selecting_a_platform_persists_it() {
        let sut = PlatformSelectionViewModel()
        sut.selectedPlatform = .bigCommerce
        XCTAssertEqual(BFFPlatformDebugStore.selected, .bigCommerce)
    }

    func test_available_platforms_lists_all_cases() {
        XCTAssertEqual(PlatformSelectionViewModel().availablePlatforms, BFFPlatform.allCases)
    }
}

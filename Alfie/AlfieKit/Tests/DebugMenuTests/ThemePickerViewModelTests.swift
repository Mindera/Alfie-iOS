import Mocks
import SharedUI
import XCTest
@testable import DebugMenu

final class ThemePickerViewModelTests: XCTestCase {
    func test_themes_areAllAppThemeCases() {
        let sut = ThemePickerViewModel(themeService: MockThemeService())
        XCTAssertEqual(sut.themes, AppTheme.allCases)
    }

    func test_selectedThemeID_fallsBackToAlfie_whenServiceHasNoSelection() {
        let sut = ThemePickerViewModel(themeService: MockThemeService(selectedThemeID: nil))
        XCTAssertEqual(sut.selectedThemeID, AppTheme.alfie.rawValue)
    }

    func test_isSelected_reflectsPersistedSelection() {
        let sut = ThemePickerViewModel(themeService: MockThemeService(selectedThemeID: AppTheme.selffridge.rawValue))
        XCTAssertTrue(sut.isSelected(.selffridge))
        XCTAssertFalse(sut.isSelected(.alfie))
    }

    func test_select_differentTheme_persistsAndReboots() {
        let service = MockThemeService(selectedThemeID: AppTheme.alfie.rawValue)
        let sut = ThemePickerViewModel(themeService: service)

        sut.select(.selffridge)

        XCTAssertEqual(service.updateThemeAndRebootCallCount, 1)
        XCTAssertEqual(service.selectedThemeID, AppTheme.selffridge.rawValue)
    }

    func test_select_alreadyActiveTheme_doesNothing() {
        let service = MockThemeService(selectedThemeID: AppTheme.alfie.rawValue)
        let sut = ThemePickerViewModel(themeService: service)

        sut.select(.alfie)

        XCTAssertEqual(service.updateThemeAndRebootCallCount, 0)
    }
}

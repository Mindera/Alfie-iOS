import XCTest
import SwiftUI
@testable import Navigation

enum TestScreen: Identifiable {
    case home
    case designers
    case bag
    case checkout
    case orderConfirmation

    var id: TestScreen {
        self
    }
}

final class NavigationAdapterTests: XCTestCase {
    private var sut: NavigationAdapter<TestScreen>!

    override func setUp() {
        super.setUp()
        sut = .init()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Push

    func test_Push_NoModal_ScreenIsAddedToPath() {
        let expectedPath = NavigationPath([TestScreen.home, TestScreen.designers])

        sut.push(.home)
        sut.push(.designers)
        XCTAssertEqual(sut.path, expectedPath)
        XCTAssertTrue(sut.modalPath.isEmpty)
    }

    func test_PushWithSheet_ScreenIsAddedToChildPath() {
        let expectedPath = NavigationPath([TestScreen.home, TestScreen.designers])
        let expectedModalPath = NavigationPath([TestScreen.bag])

        sut.push(.home)
        sut.push(.designers)

        sut.presentSheet(.checkout)
        sut.push(.bag)

        XCTAssertEqual(sut.path, expectedPath)
        XCTAssertEqual(sut.modalPath, expectedModalPath)
        XCTAssertEqual(sut.sheet, .checkout)
        XCTAssertNil(sut.fullScreenCover)
    }

    func test_PushWithFullScreenCover_ScreenIsAddedToChildPath() {
        let expectedPath = NavigationPath([TestScreen.home, TestScreen.designers])
        let expectedModalPath = NavigationPath([TestScreen.bag])

        sut.push(.home)
        sut.push(.designers)

        sut.presentFullScreenCover(.checkout)
        sut.push(.bag)

        XCTAssertEqual(sut.path, expectedPath)
        XCTAssertEqual(sut.modalPath, expectedModalPath)
        XCTAssertEqual(sut.fullScreenCover, .checkout)
        XCTAssertNil(sut.sheet)
    }

    // MARK: - Present Modal

    func test_PresentSheet_ReturnsCorrectScreen() {
        sut.push(.home)
        sut.presentSheet(.bag)

        XCTAssertTrue(sut.isPresentingSheet)
        XCTAssertFalse(sut.isPresentingFullScreenCover)
        XCTAssertEqual(sut.sheet, .bag)
        XCTAssertNil(sut.fullScreenCover)
    }

    func test_PresentFullScreenCover_ReturnsCorrectScreen() {
        sut.push(.home)
        sut.presentFullScreenCover(.bag)

        XCTAssertFalse(sut.isPresentingSheet)
        XCTAssertTrue(sut.isPresentingFullScreenCover)
        XCTAssertEqual(sut.fullScreenCover, .bag)
        XCTAssertNil(sut.sheet)
    }

    // MARK: - Replace

    func test_Replace_WithModalNavigation_ReturnsCorrectModalPath() {
        let expectedModalPath = NavigationPath([TestScreen.bag])

        sut.push(.home)
        sut.presentSheet(.designers)
        sut.push(.checkout)

        sut.replace(with: .bag)
        XCTAssertEqual(sut.modalPath, expectedModalPath)
    }

    func test_Replace_WithSeet_NoModalNavigation_ReturnsCorrectSheet() {
        sut.push(.home)
        sut.presentSheet(.designers)

        sut.replace(with: .bag)
        XCTAssertEqual(sut.sheet, .bag)
        XCTAssertNil(sut.fullScreenCover)
    }

    func test_Replace_WithFullScreenCover_NoModalNavigation_ReturnsCorrectSheet() {
        sut.push(.home)
        sut.presentFullScreenCover(.designers)

        sut.replace(with: .bag)
        XCTAssertEqual(sut.fullScreenCover, .bag)
        XCTAssertNil(sut.sheet)
    }

    func test_Replace_NoModal_NoModalNavigation_ReturnsCorrectSheet() {
        let expectedPath = NavigationPath([TestScreen.home, TestScreen.designers, TestScreen.checkout])

        sut.push(.home)
        sut.push(.designers)
        sut.push(.bag)

        sut.replace(with: .checkout)
        XCTAssertEqual(sut.path, expectedPath)
    }

    // MARK: - Remove Screens

    func test_Pop_NoModal_RemovesViewFromPath() {
        let expectedPath = NavigationPath([TestScreen.home])

        sut.push(.home)
        sut.push(.designers)

        sut.pop()

        XCTAssertEqual(sut.path, expectedPath)
        XCTAssertTrue(sut.modalPath.isEmpty)
    }

    func test_Pop_WithModal_RemovesViewFromPath() {
        let expectedPath = NavigationPath([TestScreen.home])
        let expectedModalPath = NavigationPath()

        sut.push(.home)
        sut.presentSheet(.bag)
        sut.push(.checkout)

        sut.pop()

        XCTAssertEqual(sut.path, expectedPath)
        XCTAssertEqual(sut.modalPath, expectedModalPath)
    }

    func test_PopToRoot_NoModal_ReturnsEmptyPath() {
        sut.push(.home)
        sut.push(.designers)
        sut.push(.checkout)

        sut.popToRoot()

        XCTAssertEqual(sut.path, NavigationPath())
        XCTAssertEqual(sut.modalPath, NavigationPath())
    }

    func test_PopToRoot_WithModal_ReturnsEmptyPath() {
        let expectedPath = NavigationPath([TestScreen.home, TestScreen.designers])

        sut.push(.home)
        sut.push(.designers)
        sut.presentSheet(.bag)
        sut.push(.checkout)
        sut.push(.orderConfirmation)

        sut.popToRoot()

        XCTAssertEqual(sut.path, expectedPath)
        XCTAssertEqual(sut.modalPath, NavigationPath())
        XCTAssertEqual(sut.sheet, .bag)
    }

    func test_DismissModal_Sheet_ReturnsNilSheetAndFullScreeCover() {
        let expectedPath = NavigationPath([TestScreen.home, TestScreen.designers])

        sut.push(.home)
        sut.push(.designers)
        sut.presentSheet(.checkout)
        sut.push(.orderConfirmation)

        sut.dismissModal()

        XCTAssertNil(sut.sheet)
        XCTAssertTrue(sut.modalPath.isEmpty)
        XCTAssertEqual(sut.path, expectedPath)
    }

    func test_DismissModal_FullScreenCover_ReturnsNilSheetAndFullScreeCover() {
        let expectedPath = NavigationPath([TestScreen.home, TestScreen.designers])

        sut.push(.home)
        sut.push(.designers)
        sut.presentSheet(.checkout)
        sut.push(.orderConfirmation)

        sut.dismissModal()

        XCTAssertNil(sut.sheet)
        XCTAssertTrue(sut.modalPath.isEmpty)
        XCTAssertEqual(sut.path, expectedPath)
    }
}

import XCTest
import Combine
import Core
import Models
import Mocks
@testable import Alfie

final class RecentsServiceTests: XCTestCase {
    private var mockStorageService: MockStorageService!
    private var sut: RecentsService!
    private var subscriptions: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockStorageService = .init()
        subscriptions = .init()
        sut = .init(autoSaveEnabled: true, storageService: mockStorageService, storageKey: "")
    }

    override func tearDown() {
        sut = nil
        mockStorageService = nil
        subscriptions = nil
        super.tearDown()
    }

    func test_AddRecentSearch_ReturnsCorrectRecentSearches() {
        sut.add(.recentSearch1)
        sut.add(.recentSearch2)

        XCTAssertEqual(sut.recentSearches, [.recentSearch2, .recentSearch1])
    }

    func test_AddRecentSearchPublisher_ReturnsCorrectRecentSearches() {
        sut.add(.recentSearch1)

        let recents = XCTAssertEmitsValue(
            from: sut.recentSearchesPublisher,
            afterTrigger: { sut.add(.recentSearch2) }
        )

        XCTAssertEqual(recents, [.recentSearch2, .recentSearch1])
    }

    func test_AddRecentSearchPublisher_Repeated_DoesNOTAddToRecentSearches() {
        sut.add(.recentSearch1)

        XCTAssertNoEmit(
            from: sut.recentSearchesPublisher,
            afterTrigger: { sut.add(.recentSearch1) },
            timeout: inverted
        )
    }

    func test_AddRecentSearch_WithMaxItems_RemovesLastItem() {
        let expectedRecentSearches: [RecentSearch] = [
            .recentSearch6,
            .recentSearch5,
            .recentSearch4,
            .recentSearch3,
            .recentSearch2
        ]

        sut.add(.recentSearch1)
        sut.add(.recentSearch2)
        sut.add(.recentSearch3)
        sut.add(.recentSearch4)
        sut.add(.recentSearch5)
        sut.add(.recentSearch6)

        XCTAssertEqual(sut.recentSearches, expectedRecentSearches)
    }

    func test_AddRecentSearch_WithAutoSave_SavesInStorage() throws {
        let expectation = expectation(description: "AddRecentSearch_WithAutoSave_SavesInStorage")
        mockStorageService.onSaveCalled = { _, recentSearches in
            let recentSearches = try XCTUnwrap(recentSearches as? [RecentSearch])
            XCTAssertEqual(recentSearches, [.recentSearch1])
            expectation.fulfill()
        }

        sut.add(.recentSearch1)

        waitForExpectations(timeout: `default`)
    }

    func test_RemoveRecentSearch_WhenEmptyRecentSearches_ReturnsEmptySearches() {
        sut.remove(.recentSearch1)
        XCTAssertTrue(sut.recentSearches.isEmpty)
    }

    func test_RemoveRecentSearch_ReturnsCorrectRecentSearches() {
        sut.add(.recentSearch1)
        sut.add(.recentSearch2)
        sut.add(.recentSearch3)

        sut.remove(.recentSearch2)

        XCTAssertEqual(sut.recentSearches, [.recentSearch3, .recentSearch1])
    }

    func test_RemoveRecentSearch_WithAutoSave_SavesInStorage() {
        let expectation = expectation(description: "RemoveRecentSearch_WithAutoSave_SavesInStorage")
        expectation.expectedFulfillmentCount = 2
        mockStorageService.onSaveCalled = { _, _ in
            expectation.fulfill()
        }

        sut.add(.recentSearch1)
        sut.remove(.recentSearch1)

        waitForExpectations(timeout: `default`)
    }

    func test_RemoveAll_ReturnsEmptySearches() {
        sut.add(.recentSearch1)
        sut.add(.recentSearch2)
        sut.add(.recentSearch3)

        sut.removeAll()

        XCTAssertTrue(sut.recentSearches.isEmpty)
    }
    
    func test_RemoveAll_WithAutoSave_SavesInStorage() {
        let expectation = expectation(description: "RemoveAll_WithAutoSave_SavesInStorage")
        expectation.expectedFulfillmentCount = 3
        mockStorageService.onSaveCalled = { _, _ in
            expectation.fulfill()
        }

        sut.add(.recentSearch1)
        sut.add(.recentSearch2)
        sut.removeAll()

        waitForExpectations(timeout: `default`)
    }

    func test_Save_AddRecentSearch_SavesInStorage() {
        let expectation = expectation(description: "Save_AddRecentSearch_SavesInStorage")
        mockStorageService.onSaveCalled = { _, _ in
            expectation.fulfill()
        }

        let sut = RecentsService(autoSaveEnabled: false,
                                 storageService: mockStorageService,
                                 storageKey: "")
        sut.add(.recentSearch1)
        sut.save()
        waitForExpectations(timeout: `default`)
    }

    func test_Save_RemoveRecentSearch_SavesInStorage() {
        let expectation = expectation(description: "Save_RemoveRecentSearch_SavesInStorage")
        mockStorageService.onSaveCalled = { _, _ in
            expectation.fulfill()
        }

        let sut = RecentsService(autoSaveEnabled: false, 
                                 storageService: mockStorageService,
                                 storageKey: "")
        sut.add(.recentSearch1)
        sut.remove(.recentSearch1)
        sut.save()
        waitForExpectations(timeout: `default`)
    }

    func test_Save_WithOutOperation_DoesNOTSaveInStorage() {
        let expectation = expectation(description: "Save_RemoveRecentSearch_SavesInStorage")
        expectation.isInverted = true
        mockStorageService.onSaveCalled = { _, _ in
            expectation.fulfill()
        }

        let sut = RecentsService(autoSaveEnabled: false,
                                 storageService: mockStorageService,
                                 storageKey: "")
        sut.save()
        waitForExpectations(timeout: inverted)
    }
}

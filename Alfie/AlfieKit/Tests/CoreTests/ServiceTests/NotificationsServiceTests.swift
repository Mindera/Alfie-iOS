import Mocks
import Model
import XCTest
@testable import Core

final class NotificationsServiceTests: XCTestCase {
    private var sut: NotificationsService!
    private var brazeProtocol: MockBrazeProtocolService!
    private var notificationService: MockUserNotificationService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        brazeProtocol = MockBrazeProtocolService()
        notificationService = MockUserNotificationService()
        sut = .init(braze: brazeProtocol, notificationCenter: notificationService)
    }

    override func tearDownWithError() throws {
        sut = nil
        brazeProtocol = nil
        notificationService = nil
        try super.tearDownWithError()
    }

    func test_start_with_correct_configuration() {
        sut.start()
        XCTAssertEqual(notificationService.options, [.sound, .alert, .badge])
    }
}

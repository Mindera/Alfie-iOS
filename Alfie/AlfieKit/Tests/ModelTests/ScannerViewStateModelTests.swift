import Model
import XCTest

final class ScannerViewStateModelTests: XCTestCase {
    private let notice = ScannerNotice(id: 1, message: "Not an Alfie code")

    func test_recognised_with_notice_clears_notice() {
        let state = ScannerViewStateModel(guidance: "Point at a tag", notice: notice)

        let sut = state.recognised()

        XCTAssertNil(sut.notice)
        XCTAssertTrue(sut.isRecognised)
        XCTAssertEqual(sut.guidance, "Point at a tag")
    }

    func test_with_notice_when_recognised_keeps_recognised_flag() {
        let state = ScannerViewStateModel(guidance: "Point at a tag").recognised()

        let sut = state.with(notice: notice)

        XCTAssertTrue(sut.isRecognised)
        XCTAssertEqual(sut.notice, notice)
        XCTAssertEqual(sut.guidance, "Point at a tag")
    }
}

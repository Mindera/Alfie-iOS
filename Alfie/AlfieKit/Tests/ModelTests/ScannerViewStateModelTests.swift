import Model
import XCTest

final class ScannerViewStateModelTests: XCTestCase {
    private let notice = ScannerNotice(id: 1, message: "Not an Alfie code")

    func test_recognisedClearsTheNotice() {
        let sut = ScannerViewStateModel(guidance: "Point at a tag", notice: notice).recognised()

        XCTAssertNil(sut.notice)
        XCTAssertTrue(sut.isRecognised)
        XCTAssertEqual(sut.guidance, "Point at a tag")
    }

    func test_changingTheNoticeKeepsTheRecognisedFlag() {
        let sut = ScannerViewStateModel(guidance: "Point at a tag").recognised().with(notice: notice)

        XCTAssertTrue(sut.isRecognised)
        XCTAssertEqual(sut.notice, notice)
        XCTAssertEqual(sut.guidance, "Point at a tag")
    }
}

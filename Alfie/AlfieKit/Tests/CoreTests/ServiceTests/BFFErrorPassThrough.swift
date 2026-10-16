import Model
import XCTest

extension BFFRequestError {
    static let passThroughFixture = BFFRequestError(
        type: .serverError(status: 503),
        error: URLError(.badServerResponse),
        retryCount: 2,
        graphqlErrorCode: "INTERNAL_SERVER_ERROR",
        graphqlErrorStatus: 503
    )
}

func assertPassesBFFErrorThroughUntouched(
    _ operation: () async throws -> Void,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        try await operation()
        XCTFail("Expected a throw", file: file, line: line)
    } catch let error as BFFRequestError {
        XCTAssertEqual(error.type, .serverError(status: 503), file: file, line: line)
        XCTAssertEqual(error.retryCount, 2, file: file, line: line)
        XCTAssertEqual(error.graphqlErrorCode, "INTERNAL_SERVER_ERROR", file: file, line: line)
        XCTAssertEqual(error.graphqlErrorStatus, 503, file: file, line: line)
        XCTAssertEqual((error.error as? URLError)?.code, .badServerResponse, file: file, line: line)
    } catch {
        XCTFail("Unexpected error: \(error)", file: file, line: line)
    }
}

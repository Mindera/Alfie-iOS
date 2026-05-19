import XCTest

extension XCTestCase {
    public func trackForMemoryLeak(
        _ instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(
                instance,
                "Potential memory leak: instance was not deallocated after the test ended.",
                file: file,
                line: line
            )
        }
    }
}

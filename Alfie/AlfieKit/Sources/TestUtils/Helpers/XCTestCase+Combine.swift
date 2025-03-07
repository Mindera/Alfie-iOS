import Combine
import CombineSchedulers
import XCTest

extension XCTestCase {
    @discardableResult
    public func XCTAssertEmitsValue<T, P: Publisher>(
        from publisher: P,
        filteringValues: @escaping (T) -> Bool = { _ in true },
        afterTrigger eventTrigger: () -> Void = {},
        timeout: TimeInterval = 2.0
    ) -> T? where P.Output == T, P.Failure == Never {
        var value: T?
        let eventTriggered: PassthroughSubject<Void, Never> = .init()
        let expectation = expectation(description: #function)
        var cancellable: AnyCancellable?

        cancellable = publisher
            .drop(untilOutputFrom: eventTriggered)
            .first(where: filteringValues)
            .sink { capturedValue in
                value = capturedValue
                expectation.fulfill()
            }

        eventTriggered.send()
        eventTrigger()

        wait(for: [expectation], timeout: timeout)
        cancellable?.cancel()

        return value
    }

    @discardableResult
    public func XCTAssertNoEmit<T, P: Publisher>(
        from publisher: P,
        afterTrigger eventTrigger: (() -> Void) = {},
        timeout: TimeInterval
    ) -> Bool where P.Output == T, P.Failure == Never {
        let eventTriggered: PassthroughSubject<Void, Never> = .init()
        let expectation = expectation(description: #function)
        expectation.isInverted = true
        var cancellable: AnyCancellable?

        cancellable = publisher
            .drop(untilOutputFrom: eventTriggered)
            .sink { _ in expectation.fulfill() }

        eventTriggered.send()
        eventTrigger()

        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        cancellable?.cancel()
        return result == .completed
    }

    public func XCTAssertResult<T, P: Publisher>(
        from publisher: P,
        timeout: TimeInterval = 2.0
    ) throws -> T where P.Output == T {
        var result: Result<T, Error>?
        let expectation = expectation(description: #function)
        var cancellable: AnyCancellable?

        cancellable = publisher
            .first()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        result = .failure(error)
                    }
                    expectation.fulfill()
                },
                receiveValue: { value in
                    result = .success(value)
                }
            )

        wait(for: [expectation], timeout: timeout)
        cancellable?.cancel()

        let unwrappedResult = try XCTUnwrap(result)
        return try unwrappedResult.get()
    }

    public func XCTAssertNoFailure<T, U: Equatable, P: Publisher>(
        from publisher: P,
        timeout: TimeInterval = 2.0
    ) where P.Output == T, P.Failure == U {
        let expectation = expectation(description: #function)
        var receivedError: U?
        var cancellable: AnyCancellable?

        cancellable = publisher
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )

        wait(for: [expectation], timeout: timeout)
        cancellable?.cancel()

        XCTAssertNil(receivedError)
    }

    public func XCTAssertEmitsFailure<T, U: Equatable, P: Publisher>(
        from publisher: P,
        expectedError: U? = nil,
        timeout: TimeInterval = 2.0
    ) where P.Output == T, P.Failure == U {
        let expectation = expectation(description: #function)
        var receivedError: U?
        var cancellable: AnyCancellable?

        cancellable = publisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        if expectedError != nil {
                            XCTFail("Expected failure but received completion")
                        }

                    case .failure(let error):
                        receivedError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )

        wait(for: [expectation], timeout: timeout)
        cancellable?.cancel()

        if let expectedError {
            XCTAssertEqual(expectedError, receivedError)
        } else {
            XCTAssertNotNil(receivedError)
        }
    }
}

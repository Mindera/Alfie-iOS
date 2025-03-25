import Combine
import CombineSchedulers
import XCTest

extension XCTestCase {
    @discardableResult
    public func XCTAssertEmitsValue<P: Publisher>(
        from publisher: P,
        where predicate: @escaping (P.Output) -> Bool = { _ in true },
        afterTrigger eventTrigger: @escaping () -> Void = {},
        timeout: TimeInterval = .default
    ) -> P.Output? where P.Failure == Never {
        var value: P.Output?
        let eventTriggered: PassthroughSubject<Void, Never> = .init()
        let expectation = expectation(description: #function)
        var cancellable: AnyCancellable?

        cancellable = publisher
            .drop(untilOutputFrom: eventTriggered)
            .first(where: predicate)
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

    public func XCTAssertEmitsValueEqualTo<P: Publisher>(
        from publisher: P,
        expectedValue: P.Output,
        afterTrigger eventTrigger: @escaping () -> Void = {},
        timeout: TimeInterval = .default
    ) where P.Failure == Never, P.Output: Equatable {
        XCTAssertEmitsValue(
            from: publisher,
            where: { $0 == expectedValue },
            afterTrigger: eventTrigger,
            timeout: timeout
        )
    }

    public func XCTAssertEmitsValueNotEqualTo<P: Publisher>(
        from publisher: P,
        unexpectedValue: P.Output,
        afterTrigger eventTrigger: @escaping () -> Void = {},
        timeout: TimeInterval = .default
    ) where P.Failure == Never, P.Output: Equatable {
        XCTAssertEmitsValue(
            from: publisher,
            where: { $0 != unexpectedValue },
            afterTrigger: eventTrigger,
            timeout: timeout
        )
    }

    public func XCTAssertNoEmit<P: Publisher>(
        from publisher: P,
        afterTrigger eventTrigger: @escaping (() -> Void) = {},
        timeout: TimeInterval = .inverted
    ) where P.Failure == Never {
        let eventTriggered: PassthroughSubject<Void, Never> = .init()
        let expectation = expectation(description: #function)
        expectation.isInverted = true
        var cancellable: AnyCancellable?

        cancellable = publisher
            .drop(untilOutputFrom: eventTriggered)
            .sink { _ in expectation.fulfill() }

        eventTriggered.send()
        eventTrigger()

        wait(for: [expectation], timeout: timeout)
        cancellable?.cancel()
    }

    public func XCTAssertResult<P: Publisher>(
        from publisher: P,
        timeout: TimeInterval = .default
    ) throws -> P.Output {
        var result: Result<P.Output, Error>?
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

    public func XCTAssertNoFailure<P: Publisher>(
        from publisher: P,
        timeout: TimeInterval = .default
    ) {
        let expectation = expectation(description: #function)
        var receivedError: P.Failure?
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

    public func XCTAssertEmitsFailure<P: Publisher>(
        from publisher: P,
        timeout: TimeInterval = .default,
        errorHandler: @escaping (_ error: P.Failure) -> Void
    ) {
        let expectation = expectation(description: #function)
        var receivedError: P.Failure?
        var cancellable: AnyCancellable?

        cancellable = publisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("Expected failure but received completion")

                    case .failure(let error):
                        receivedError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )

        wait(for: [expectation], timeout: timeout)
        cancellable?.cancel()

        if let receivedError {
            errorHandler(receivedError)
        } else {
            XCTFail("Expected error but didn't receive any error")
        }
    }
}

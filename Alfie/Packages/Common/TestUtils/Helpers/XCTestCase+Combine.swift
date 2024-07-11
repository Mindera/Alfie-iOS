import Combine
import XCTest

extension XCTestCase {
    public func waitUntil<T: Equatable>(publisher: AnyPublisher<T, Never>, emitsValue: T, asyncOperation: (() -> Void)? = nil, timeout: TimeInterval = 2.0) {
        let exp = expectation(description: "publisher emits value")
        var subscriptions: Set<AnyCancellable> = []

        publisher.sink { value in
            guard value == emitsValue else {
                return
            }
            exp.fulfill()
        }.store(in: &subscriptions)

        asyncOperation?()

        waitForExpectations(timeout: timeout, handler: nil)
    }

    public func waitUntil<T: Equatable>(
        _ propertyPublisher: Published<T>.Publisher,
        equals expectedValue: T,
        timeout: TimeInterval = 2.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let expectation = expectation(description: "Awaiting value \(expectedValue) to be issued")
        var cancellable: AnyCancellable?
        cancellable = propertyPublisher
            .dropFirst()
            .first(where: { $0 == expectedValue })
            .sink { value in
                XCTAssertEqual(value, expectedValue, file: file, line: line)
                cancellable?.cancel()
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: timeout)
    }

    public func captureEvent<P: Publisher>(fromPublisher publisher: P, afterTrigger eventTrigger: () -> Void, timeout: TimeInterval = 2.0) -> P.Output? where P.Failure == Never {
        var value: P.Output?
        let eventTriggered: PassthroughSubject<Void, Never> = .init()
        let exp = expectation(description: #function)
        var subscriptions: Set<AnyCancellable> = []

        publisher
            .drop(untilOutputFrom: eventTriggered)
            .sink { publisherValue in
                value = publisherValue
                exp.fulfill()
            }.store(in: &subscriptions)

        eventTriggered.send()
        eventTrigger()

        waitForExpectations(timeout: timeout, handler: nil)
        return value
    }

    public func assertNoEvent<T>(from publisher: AnyPublisher<T, Never>, afterTrigger eventTrigger: () -> Void, timeout: TimeInterval = 3.0) -> Bool {
        let eventTriggered: PassthroughSubject<Void, Never> = .init()
        var subscriptions: Set<AnyCancellable> = []
        let exp = expectation(description: #function)
        exp.isInverted = true

        publisher
            .drop(untilOutputFrom: eventTriggered)
            .sink { _ in
                exp.fulfill()
            }.store(in: &subscriptions)

        eventTriggered.send()
        eventTrigger()

        let result = XCTWaiter().wait(for: [exp], timeout: timeout)
        return result == .completed
    }

    public func assertNoEvent<T, U>(from publisher: AnyPublisher<T, U>, timeout: TimeInterval = 2.0) -> Bool {
        var subscriptions: Set<AnyCancellable> = []
        let exp = expectation(description: #function)
        exp.isInverted = true

        publisher
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in
                exp.fulfill()
            }).store(in: &subscriptions)

        let result = XCTWaiter().wait(for: [exp], timeout: timeout)
        return result == .completed
    }

    public func captureLastEvent<T>(fromPublisher publisher: AnyPublisher<T, Never>,
                                    filteringValues: @escaping (T) -> Bool = { _ in true },
                                    eventTrigger: () -> Void,
                                    timeout: TimeInterval = 2.0) -> T? {
        var subscriptions: Set<AnyCancellable> = []
        var value: T?
        let exp = expectation(description: "capture first event")
        // swiftlint:disable:next last_where
        publisher
            .filter(filteringValues)
            .last()
            .sink { publisherValue in
                value = publisherValue
                exp.fulfill()
            }.store(in: &subscriptions)

        eventTrigger()

        waitForExpectations(timeout: timeout, handler: nil)

        return value
    }

    public func array<T>(fromPublisher publisher: AnyPublisher<T, Never>, during duration: TimeInterval = 1.0) -> [T] {
        var subscriptions: Set<AnyCancellable> = []
        var values: [T] = []

        publisher.sink { value in
            values.append(value)
        }.store(in: &subscriptions)

        sleep(UInt32(duration))
        return values
    }

    public func waitResult<T: Publisher>(publisher: T, timeout: TimeInterval = 2.0) throws -> T.Output {
        var result: Result<T.Output, Error>?
        let exp = expectation(description: #function)

        let cancellable = publisher
            .first()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                        case .failure(let error):
                            result = .failure(error)
                        case .finished:
                            break
                    }
                    exp.fulfill()
                },
                receiveValue: { value in
                    result = .success(value)
                }
            )

        waitForExpectations(timeout: timeout)
        cancellable.cancel()

        let unwrappedResult = try XCTUnwrap(result)
        return try unwrappedResult.get()
    }

    public func assertNoFailure<T, U>(from publisher: AnyPublisher<T, U>, timeout: TimeInterval = 2.0) {
        let expectation = self.expectation(description: "assert no failure and stream completion")
        var error: U?
        var isCompletionCalled = false
        _ = publisher
            .sink(receiveCompletion: { completion in
                isCompletionCalled = true
                switch completion {
                    case .finished:
                        break
                    case .failure(let failure):
                        error = failure
                }
                expectation.fulfill()
            }, receiveValue: { _ in
                // do nothing
            })

        waitForExpectations(timeout: timeout)

        XCTAssertNil(error)
        XCTAssertTrue(isCompletionCalled)
    }

    public func assertFailure<T, U: Equatable>(from publisher: AnyPublisher<T, U>, with expectedError: U? = nil, timeout: TimeInterval = 2.0) {
        let expectation = self.expectation(description: #function)
        var error: U?
        var subscriptions: Set<AnyCancellable> = []

        publisher
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .finished:
                        break
                    case .failure(let failure):
                        error = failure
                }
                expectation.fulfill()
            }, receiveValue: { _ in
                // do nothing
            }).store(in: &subscriptions)

        waitForExpectations(timeout: 3)

        if expectedError != nil {
            XCTAssertEqual(expectedError, error)
        } else {
            XCTAssertNotNil(error)
        }
    }

    public func assertAnyFailure<T, U>(from publisher: AnyPublisher<T, U>, timeout: TimeInterval = 2.0) {
        let expectation = self.expectation(description: #function)
        var subscriptions: Set<AnyCancellable> = []

        publisher
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .finished:
                        break
                    case .failure:
                        expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Failure")
            }).store(in: &subscriptions)

        waitForExpectations(timeout: 3)
    }
}

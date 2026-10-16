import XCTest

actor ResponseGate {
    private var continuation: CheckedContinuation<Void, Never>?
    private var opened = false

    func hold(signal: XCTestExpectation) async {
        signal.fulfill()
        guard !opened else { return }
        await withCheckedContinuation { continuation = $0 }
    }

    func open() {
        opened = true
        continuation?.resume()
        continuation = nil
    }
}

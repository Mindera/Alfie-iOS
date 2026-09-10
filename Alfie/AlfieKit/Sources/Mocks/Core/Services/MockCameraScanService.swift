import Combine
import Model
import SwiftUI

public final class MockCameraScanService: CameraScanServiceProtocol {
    private let subject = PassthroughSubject<String, Never>()
    public var recognisedPayloadPublisher: AnyPublisher<String, Never> { subject.eraseToAnyPublisher() }

    private let failureSubject = PassthroughSubject<CameraScanFailure, Never>()
    public var failurePublisher: AnyPublisher<CameraScanFailure, Never> { failureSubject.eraseToAnyPublisher() }

    public private(set) var startCount = 0
    public private(set) var stopCount = 0
    /// What the camera would be doing, inferred from the calls made rather than tracked separately,
    /// so a test cannot assert a state the service was never actually put into.
    public var isScanning: Bool { startCount > stopCount }

    public init() { }

    public func makePreview() -> AnyView {
        AnyView(EmptyView())
    }

    public func startScanning() {
        startCount += 1
    }

    public func stopScanning() {
        stopCount += 1
    }

    /// Drives the seam: stands in for the camera seeing a code.
    public func recognise(_ payload: String) {
        subject.send(payload)
    }

    /// Drives the other half of the seam: stands in for there being no camera to see with.
    public func fail(with failure: CameraScanFailure) {
        failureSubject.send(failure)
    }
}

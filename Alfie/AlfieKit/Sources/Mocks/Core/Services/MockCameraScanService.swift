import Combine
import Model
import SwiftUI

public final class MockCameraScanService: CameraScanServiceProtocol {
    private let subject = PassthroughSubject<[String], Never>()
    public var recognisedPayloadsPublisher: AnyPublisher<[String], Never> { subject.eraseToAnyPublisher() }

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
        recognise([payload])
    }

    /// Stands in for everything the camera is holding — a Swing tag showing its Barcode and its
    /// Alfie code at once. Call it again with a longer list to stand in for a code joining the ones
    /// already tracked, which is how the real scanner acquires the second of a pair.
    public func recognise(_ payloads: [String]) {
        subject.send(payloads)
    }

    /// Drives the other half of the seam: stands in for there being no camera to see with.
    public func fail(with failure: CameraScanFailure) {
        failureSubject.send(failure)
    }
}

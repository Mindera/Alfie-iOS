import Combine
import Model
import SwiftUI

public final class MockCameraScanService: CameraScanServiceProtocol {
    private let subject = PassthroughSubject<[ScannedPayload], Never>()
    public var recognisedPayloadsPublisher: AnyPublisher<[ScannedPayload], Never> { subject.eraseToAnyPublisher() }

    private let failureSubject = PassthroughSubject<CameraScanFailure, Never>()
    public var failurePublisher: AnyPublisher<CameraScanFailure, Never> { failureSubject.eraseToAnyPublisher() }

    public var canAskForCameraAccess = false

    public var onStartScanningCalled: (() -> Void)?
    public var onStopScanningCalled: (() -> Void)?

    public init() { }

    public func makePreview() -> AnyView {
        AnyView(EmptyView())
    }

    public func startScanning() {
        onStartScanningCalled?()
    }

    public func stopScanning() {
        onStopScanningCalled?()
    }

    /// Drives the seam: stands in for the camera seeing a code.
    public func recognise(_ payload: ScannedPayload) {
        recognise([payload])
    }

    /// Stands in for everything the camera is holding — a Swing tag showing its Barcode and its
    /// Alfie code at once. Call it again with a longer list to stand in for a code joining the ones
    /// already tracked, which is how the real scanner acquires the second of a pair.
    public func recognise(_ payloads: [ScannedPayload]) {
        subject.send(payloads)
    }

    /// Drives the other half of the seam: stands in for there being no camera to see with.
    public func fail(with failure: CameraScanFailure) {
        failureSubject.send(failure)
    }
}

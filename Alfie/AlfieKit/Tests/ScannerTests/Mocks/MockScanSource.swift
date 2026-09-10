import Combine
import SwiftUI
@testable import Scanner

/// A camera a test can drive: `recognise(_:)` puts a payload through the seam exactly as the real
/// scanner would, and the start/stop counters record what the ViewModel asked the camera to do.
final class MockScanSource: ScanSourceProtocol {
    private let subject = PassthroughSubject<String, Never>()

    var recognisedPayloadPublisher: AnyPublisher<String, Never> { subject.eraseToAnyPublisher() }

    private(set) var startCount = 0
    private(set) var stopCount = 0
    var isScanning: Bool { startCount > stopCount }

    func makePreview() -> AnyView {
        AnyView(EmptyView())
    }

    func startScanning() {
        startCount += 1
    }

    func stopScanning() {
        stopCount += 1
    }

    func recognise(_ payload: String) {
        subject.send(payload)
    }
}

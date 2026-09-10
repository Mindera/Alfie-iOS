import SwiftUI

public protocol ScannerViewModelProtocol: ObservableObject {
    var title: String { get }
    var guidance: String { get }
    /// The camera preview supplied by the scan source.
    var preview: AnyView { get }

    func viewDidAppear()
    func viewDidDisappear()
    /// Recognition may only run while the app is in the foreground: a camera left running behind a
    /// backgrounded app is both a battery cost and a privacy one.
    func didChangeScenePhase(isActive: Bool)
    func didTapClose()
}

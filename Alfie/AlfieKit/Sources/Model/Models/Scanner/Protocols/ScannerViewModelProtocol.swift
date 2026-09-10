import SwiftUI

public protocol ScannerViewModelProtocol: ObservableObject {
    var title: String { get }
    /// `.success` while there is a camera to look through — with or without a notice over it — and
    /// `.error` when there is not. There is no `.loading`: nothing is fetched, so the screen has
    /// something to say from the moment it opens.
    var state: ViewState<ScannerViewStateModel, ScannerViewErrorType> { get }
    /// The camera preview supplied by the scan source.
    var preview: AnyView { get }

    func viewDidAppear()
    func viewDidDisappear()
    /// Recognition may only run while the app is in the foreground: a camera left running behind a
    /// backgrounded app is both a battery cost and a privacy one.
    func didChangeScenePhase(isActive: Bool)
    func didTapClose()
    /// The notice has been read and dismissed. The camera never stopped, so there is nothing to resume.
    func didDismissNotice()
    /// Only offered for ``ScannerViewErrorType/cameraPermissionDenied``: it is the one failure the
    /// shopper can undo, and only from outside the app.
    func didTapOpenSettings()
}

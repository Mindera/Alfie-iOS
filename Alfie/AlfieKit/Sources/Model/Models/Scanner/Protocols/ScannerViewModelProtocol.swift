import SwiftUI

public protocol ScannerViewModelProtocol: ObservableObject {
    var title: String { get }
    /// `.success` while there is a camera to look through — with or without a notice over it — and
    /// `.error` when there is not. There is no `.loading`: nothing is fetched, so the screen has
    /// something to say from the moment it opens.
    var state: ViewState<ScannerViewStateModel, ScannerViewErrorType> { get }
    /// The camera preview supplied by the scan source.
    var preview: AnyView { get }
    /// What to point the camera at, while there is a camera to point it with.
    ///
    /// Read off ``state`` here rather than in the View: the walk into the state model belongs on
    /// this side of the seam, as it does for every other screen.
    var guidance: String? { get }
    /// Why there is no camera to look through, or `nil` while there is one. Read off ``state`` for
    /// the same reason as ``guidance``.
    var failure: ScannerViewErrorType? { get }
    /// What the shopper was last told about a code, if anything.
    var notice: ScannerNotice? { get }
    var isRecognised: Bool { get }
    var isLookingUp: Bool { get }
    var isExplainingCameraAccess: Bool { get }

    func viewDidAppear()
    func viewDidDisappear()
    /// Recognition may only run while the app is in the foreground: a camera left running behind a
    /// backgrounded app is both a battery cost and a privacy one.
    func didChangeScenePhase(isActive: Bool)
    func didTapClose()
    func didTapContinueToCamera()
    func didDeclineCameraAccess()
    /// The notice has been read and dismissed. The camera never stopped, so there is nothing to resume.
    func didDismissNotice()
    /// Only offered for ``ScannerViewErrorType/cameraPermissionDenied``: it is the one failure the
    /// shopper can undo, and only from outside the app.
    func didTapOpenSettings()
}

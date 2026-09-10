import AccessibilityIdentifiers
import Model
import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif

/// The scanner screen: a full-bleed camera preview, the guidance that tells the shopper what to
/// point it at, and a way out.
///
/// Presented modally rather than pushed — it adds no navigation route, because a successful scan
/// leaves through the deep-link path instead of a route of its own.
///
/// Nothing here is ever blank. A code that is not ours puts a notice over a camera that keeps
/// running, and a camera that cannot run at all is replaced by ``ScannerFailureView`` — the header
/// and its way out survive both, and invert with whatever ends up behind them.
public struct ScannerView<ViewModel: ScannerViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel
    @Environment(\.scenePhase) private var scenePhase

    public init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        ZStack(alignment: .top) {
            if let error = viewModel.state.failure {
                ScannerFailureView(error: error, openSettings: { viewModel.didTapOpenSettings() })
            } else {
                camera
            }

            header
                .padding(theme.spacing.space200)
        }
        .background(isShowingCamera ? Theme.surfaceBackgroundInvertedPrimary : Theme.surfaceBackgroundPrimary)
        .accessibilityIdentifier(AccessibilityID.Scanner.screen)
        .onAppear { viewModel.viewDidAppear() }
        .onDisappear { viewModel.viewDidDisappear() }
        .onChange(of: scenePhase) { phase in
            viewModel.didChangeScenePhase(isActive: phase == .active)
        }
        // A notice arrives while the shopper is looking through the camera, not at the text, so
        // seeing it is not the same as being told it. VoiceOver has to be spoken to directly.
        //
        // Keyed on the whole notice rather than its words: a second bad code in a row says the same
        // thing, and it is exactly then that the shopper most needs telling. ``ScannerNotice``
        // carries an identity so that repeat still reads as a change.
        .onChange(of: notice) { notice in
            guard let notice else { return }
            UIAccessibility.post(notification: .announcement, argument: notice.message)
        }
    }

    private var isShowingCamera: Bool {
        viewModel.state.failure == nil
    }

    /// What the shopper was last told about a code, if anything. Read in three places, so the walk
    /// into the state is done once here rather than repeated at each of them.
    private var notice: ScannerNotice? {
        viewModel.state.value?.notice
    }

    private var guidanceText: String? {
        viewModel.state.value?.guidance
    }

    private var camera: some View {
        ZStack(alignment: .top) {
            viewModel.preview
                .ignoresSafeArea()
                .accessibilityHidden(true)

            messages
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.horizontal, theme.spacing.space400)
                .padding(.bottom, theme.spacing.space600)
        }
    }

    /// The title is centred on the screen, not on the space left over by the close button, so it
    /// does not shift when the button's size changes with Dynamic Type.
    private var header: some View {
        ZStack {
            Text.build(theme.font.heading.medium(viewModel.title))
                .foregroundStyle(chromeForeground)
                .accessibilityIdentifier(AccessibilityID.Scanner.title)
                .accessibilityAddTraits(.isHeader)

            closeButton
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var closeButton: some View {
        Button {
            viewModel.didTapClose()
        } label: {
            ThemedIcon(.close, size: .medium, tint: chromeForeground)
                .padding(theme.spacing.space150)
                .background(chromeBackground)
        }
        .accessibilityIdentifier(AccessibilityID.Scanner.close)
        .accessibilityLabel(Text(L10n.Accessibility.close))
    }

    /// The guidance, and the notice about the last code when there is one. Both sit at the bottom
    /// rather than one replacing the other: a shopper who has just scanned the wrong thing needs
    /// telling *and* still needs to know what to point at.
    @ViewBuilder private var messages: some View {
        VStack(spacing: theme.spacing.space200) {
            if let notice {
                SnackbarView(
                    configuration: .init(
                        type: .error,
                        text: notice.message,
                        showCloseButton: true,
                        icon: Icon.warning.image,
                        autoDismissTime: nil
                    ),
                    onCloseTap: { viewModel.didDismissNotice() }
                )
                .accessibilityIdentifier(AccessibilityID.Scanner.notice)
            }

            guidance
        }
    }

    /// Left as plain text in reading order: a shopper using VoiceOver cannot see what the camera is
    /// being asked to look at, so the guidance has to be reached on the way through the screen
    /// rather than hidden behind the preview.
    @ViewBuilder private var guidance: some View {
        if let guidance = guidanceText {
            Text.build(theme.font.body.medium(guidance))
                .foregroundStyle(Theme.contentContentInvertedPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, theme.spacing.space300)
                .padding(.vertical, theme.spacing.space200)
                .background(
                    RoundedRectangle(cornerRadius: Sizing.radiusSoft)
                        .fill(Theme.surfaceBackgroundInvertedPrimary.opacity(Constants.chromeOpacity))
                )
                .accessibilityIdentifier(AccessibilityID.Scanner.guidance)
        }
    }

    /// The chrome sits over a live camera in the ordinary case and over a plain background in the
    /// failure cases, so it inverts with what is behind it.
    private var chromeForeground: Color {
        isShowingCamera ? Theme.contentContentInvertedPrimary : Theme.contentContentPrimary
    }

    @ViewBuilder private var chromeBackground: some View {
        if isShowingCamera {
            Circle().fill(Theme.surfaceBackgroundInvertedPrimary.opacity(Constants.chromeOpacity))
        }
    }
}

private enum Constants {
    /// The chrome sits over a live preview, so it is legible without hiding what the camera sees.
    static let chromeOpacity: Double = 0.6
}

#if DEBUG
#Preview("Scanning") {
    ScannerView(viewModel: MockScannerViewModel())
}

#Preview("Unrecognised code") {
    ScannerView(
        viewModel: MockScannerViewModel(
            state: .success(
                .init(
                    guidance: "Point the camera at the Alfie code on the tag",
                    notice: .init(id: 1, message: "That code doesn't open anything in Alfie.")
                )
            )
        )
    )
}

#Preview("Permission denied") {
    ScannerView(viewModel: MockScannerViewModel(state: .error(.cameraPermissionDenied)))
}

#Preview("Device not supported") {
    ScannerView(viewModel: MockScannerViewModel(state: .error(.deviceNotSupported)))
}

#Preview("Camera unavailable") {
    ScannerView(viewModel: MockScannerViewModel(state: .error(.generic)))
}
#endif

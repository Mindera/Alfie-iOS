import AccessibilityIdentifiers
import Model
import SharedUI
import SwiftUI
import Utils
#if DEBUG
import Mocks
#endif

/// The scanner screen: the camera preview with a viewfinder, the guidance that tells the shopper
/// what to point it at, and a way back.
///
/// Presented modally rather than pushed — it adds no navigation route, because a successful scan
/// leaves through the deep-link path instead of a route of its own.
///
/// Nothing here is ever blank. A code that is not ours puts a notice over a camera that keeps
/// running, and a camera that cannot run at all is replaced by ``ScannerFailureView`` — the header
/// and its way out survive both.
public struct ScannerView<ViewModel: ScannerViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var introSize: CGSize = .zero

    public init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        Group {
            if viewModel.isExplainingCameraAccess {
                Color.clear
            } else {
                screen
            }
        }
        .sheet(isPresented: isIntroPresented) {
            ScannerIntroView(
                onContinue: { viewModel.didTapContinueToCamera() },
                onNotNow: { viewModel.didDeclineCameraAccess() }
            )
            .writingSize(to: $introSize)
            .frame(maxHeight: .infinity, alignment: .top)
            .presentationDetents(introSize == .zero ? [.medium] : [.height(introSize.height)])
        }
    }

    private var isIntroPresented: Binding<Bool> {
        Binding(
            get: { viewModel.isExplainingCameraAccess },
            set: { isPresented in
                guard !isPresented else { return }
                viewModel.didDeclineCameraAccess()
            }
        )
    }

    private var screen: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, theme.spacing.space200)
                .padding(.vertical, theme.spacing.space150)
                .background(Theme.surfaceBackgroundInvertedPrimary.ignoresSafeArea(edges: .top))

            if let error = viewModel.state.failure {
                ScannerFailureView(error: error, openSettings: { viewModel.didTapOpenSettings() })
                    .frame(maxHeight: .infinity)
                    .background(Theme.surfaceBackgroundPrimary)
            } else {
                camera
            }
        }
        .background(isShowingCamera ? Theme.surfaceBackgroundInvertedPrimary : Theme.surfaceBackgroundPrimary)
        .accessibilityIdentifier(AccessibilityID.Scanner.screen)
        .onAppear {
            viewModel.viewDidAppear()
            announceGuidance()
        }
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
        .onChange(of: viewModel.notice) { notice in
            guard let notice else { return }
            UIAccessibility.post(notification: .announcement, argument: notice.message)
        }
        .onChange(of: viewModel.isLookingUp) { isLookingUp in
            guard isLookingUp else { return }
            UIAccessibility.post(notification: .announcement, argument: L10n.Scanner.Lookup.message)
        }
    }

    private var isShowingCamera: Bool {
        viewModel.state.failure == nil
    }

    /// The screen opens straight onto a live camera, so a shopper using VoiceOver has nothing to read
    /// and no reason to know what to point it at unless they are told.
    ///
    /// Posted as `.screenChanged` rather than `.announcement`: the screen is being presented at this
    /// moment, and a plain announcement made into that moment is routinely dropped in favour of the
    /// focus change that follows it. `.screenChanged` is that focus change, and speaks its argument.
    private func announceGuidance() {
        guard let guidance = viewModel.guidance else { return }
        UIAccessibility.post(notification: .screenChanged, argument: guidance)
    }

    private var camera: some View {
        ZStack {
            viewModel.preview
                .ignoresSafeArea(edges: .bottom)
                .accessibilityHidden(true)

            VStack(spacing: theme.spacing.space300) {
                viewfinder
                if viewModel.isLookingUp {
                    lookup
                } else {
                    guidance
                }
            }
            .padding(.horizontal, theme.spacing.space400)

            notice
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.horizontal, theme.spacing.space200)
                .padding(.bottom, theme.spacing.space400)
        }
    }

    /// The title is centred on the screen, not on the space left over by the back button, so it
    /// does not shift when the button's size changes with Dynamic Type.
    private var header: some View {
        ZStack {
            Text.build(theme.font.heading.medium(viewModel.title))
                .foregroundStyle(Theme.contentContentInvertedPrimary)
                .accessibilityIdentifier(AccessibilityID.Scanner.title)
                .accessibilityAddTraits(.isHeader)

            backButton
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var backButton: some View {
        Button {
            viewModel.didTapClose()
        } label: {
            ThemedIcon(.chevronLeft, size: .medium, tint: Theme.contentContentInvertedPrimary)
        }
        .accessibilityIdentifier(AccessibilityID.Scanner.back)
        .accessibilityLabel(Text(L10n.Accessibility.back))
    }

    private var viewfinder: some View {
        RoundedRectangle(cornerRadius: Sizing.radiusSoft)
            .stroke(
                viewModel.isRecognised ? Theme.contentContentPositive : Theme.borderSoft,
                lineWidth: Constants.viewfinderLineWidth
            )
            .frame(width: Constants.viewfinderSide, height: Constants.viewfinderSide)
            .animation(.easeOut(duration: Constants.viewfinderAnimationDuration), value: viewModel.isRecognised)
            .accessibilityHidden(true)
    }

    /// Left as plain text in reading order: a shopper using VoiceOver cannot see what the camera is
    /// being asked to look at, so the guidance has to be reached on the way through the screen
    /// rather than hidden behind the preview.
    @ViewBuilder private var guidance: some View {
        if let guidance = viewModel.guidance {
            Text.build(theme.font.body.small(guidance))
                .foregroundStyle(Theme.contentContentInvertedPrimary)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier(AccessibilityID.Scanner.guidance)
        }
    }

    private var lookup: some View {
        VStack(spacing: theme.spacing.space150) {
            LoaderView(circleDiameter: .defaultSmall, style: .light)
            Text.build(theme.font.body.small(L10n.Scanner.Lookup.message))
                .foregroundStyle(Theme.contentContentInvertedPrimary)
                .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(AccessibilityID.Scanner.lookup)
    }

    @ViewBuilder private var notice: some View {
        if let notice = viewModel.notice {
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
            .transition(.opacity)
        }
    }

}

private enum Constants {
    static let viewfinderSide: CGFloat = 250
    static let viewfinderLineWidth: CGFloat = 2
    static let viewfinderAnimationDuration: TimeInterval = 0.15
}

#if DEBUG
#Preview("Scanning") {
    ScannerView(viewModel: MockScannerViewModel())
}

#Preview("Recognised") {
    ScannerView(
        viewModel: MockScannerViewModel(
            state: .success(.init(guidance: L10n.Scanner.Guidance.message, isRecognised: true))
        )
    )
}

#Preview("Looking up Barcode") {
    ScannerView(
        viewModel: MockScannerViewModel(
            state: .success(.init(guidance: L10n.Scanner.Guidance.message, isLookingUp: true))
        )
    )
}

#Preview("Camera access intro") {
    ScannerView(viewModel: MockScannerViewModel(isExplainingCameraAccess: true))
}

#Preview("Unrecognised code") {
    ScannerView(
        viewModel: MockScannerViewModel(
            state: .success(
                .init(
                    guidance: L10n.Scanner.Guidance.message,
                    notice: .init(id: 1, message: L10n.Scanner.Unrecognised.message)
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

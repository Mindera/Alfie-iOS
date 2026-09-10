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
public struct ScannerView<ViewModel: ScannerViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel
    @Environment(\.scenePhase) private var scenePhase

    public init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        ZStack(alignment: .top) {
            viewModel.preview
                .ignoresSafeArea()
                .accessibilityHidden(true)

            header
                .padding(theme.spacing.space200)

            guidance
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.horizontal, theme.spacing.space400)
                .padding(.bottom, theme.spacing.space600)
        }
        .background(Theme.surfaceBackgroundInvertedPrimary)
        .accessibilityIdentifier(AccessibilityID.Scanner.screen)
        .onAppear { viewModel.viewDidAppear() }
        .onDisappear { viewModel.viewDidDisappear() }
        .onChange(of: scenePhase) { phase in
            viewModel.didChangeScenePhase(isActive: phase == .active)
        }
    }

    /// The title is centred on the screen, not on the space left over by the close button, so it
    /// does not shift when the button's size changes with Dynamic Type.
    private var header: some View {
        ZStack {
            Text.build(theme.font.heading.medium(viewModel.title))
                .foregroundStyle(Theme.contentContentInvertedPrimary)
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
            ThemedIcon(.close, size: .medium, tint: Theme.contentContentInvertedPrimary)
                .padding(theme.spacing.space150)
                .background(Circle().fill(Theme.surfaceBackgroundInvertedPrimary.opacity(Constants.chromeOpacity)))
        }
        .accessibilityIdentifier(AccessibilityID.Scanner.close)
        .accessibilityLabel(Text(L10n.Accessibility.close))
    }

    /// Left as plain text in reading order: a shopper using VoiceOver cannot see what the camera is
    /// being asked to look at, so the guidance has to be reached on the way through the screen
    /// rather than hidden behind the preview.
    private var guidance: some View {
        Text.build(theme.font.body.medium(viewModel.guidance))
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

private enum Constants {
    /// The chrome sits over a live preview, so it is legible without hiding what the camera sees.
    static let chromeOpacity: Double = 0.6
}

#if DEBUG
#Preview {
    ScannerView(viewModel: MockScannerViewModel())
}
#endif

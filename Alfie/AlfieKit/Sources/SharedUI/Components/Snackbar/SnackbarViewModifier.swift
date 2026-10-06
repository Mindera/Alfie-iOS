import SwiftUI

/// Adds  a snackbar to a view, configured using a `SnackbarViewConfiguration`, that can be set to nil to hide the snackbar
public struct SnackbarViewModifier: ViewModifier {
    @Binding public var configuration: SnackbarViewConfiguration?

    public init(configuration: Binding<SnackbarViewConfiguration?>) {
        self._configuration = configuration
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                ZStack {
                    snackbarView
                        .padding(Primitives.Spacing.spacing8)
                }
                .animation(.spring(), value: configuration),
                alignment: alignment
            )
            .task(id: configuration) {
                await dismissAutomaticallyIfNecessary()
            }
    }

    public func dismiss() {
        let completion = configuration?.onDismiss
        defer {
            completion?()
        }

        withAnimation {
            configuration = nil
        }
    }

    // MARK: - Private

    @ViewBuilder private var snackbarView: some View {
        if let configuration {
            VStack {
                SnackbarView(configuration: configuration) { dismiss() }
            }
            .transition(
                AnyTransition.opacity.combined(
                    with: AnyTransition.move(edge: configuration.showFromTop ? .top : .bottom)
                )
            )
        }
    }

    private var alignment: Alignment {
        guard let configuration else {
            return .center
        }

        return configuration.showFromTop ? .top : .bottom
    }

    @MainActor
    private func dismissAutomaticallyIfNecessary() async {
        guard
            let autoDismissTime = configuration?.autoDismissTime,
            autoDismissTime > 0
        else {
            return
        }

        try? await Task.sleep(nanoseconds: UInt64(autoDismissTime * Double(NSEC_PER_SEC)))
        guard !Task.isCancelled else {
            return
        }

        dismiss()
    }
}

public extension View {
    /// Helper extension to add a snackbar to a view, configured using a `SnackbarViewConfiguration`, that can be set to nil to hide the snackbar
    func snackbarView(configuration: Binding<SnackbarViewConfiguration?>) -> some View {
        self.modifier(SnackbarViewModifier(configuration: configuration))
    }
}

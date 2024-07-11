import SwiftUI

/// Adds  a snackbar to a view, configured using a `SnackbarViewConfiguration`, that can be set to nil to hide the snackbar
public struct SnackbarViewModifier: ViewModifier {
    @Binding public var configuration: SnackbarViewConfiguration?
    @State private var workItem: DispatchWorkItem?

    public init(configuration: Binding<SnackbarViewConfiguration?>) {
        self._configuration = configuration
        scheduleDismissIfNecessary()
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                ZStack {
                    snackbarView
                        .padding(Spacing.space100)
                }
                .animation(.spring(), value: configuration),
                alignment: alignment)
    }

    public func dismiss() {
        let completion = configuration?.onDismiss
        defer {
            completion?()
        }

        workItem?.cancel()
        workItem = nil

        withAnimation {
            configuration = nil
        }
    }

    // MARK: - Private

    @ViewBuilder private var snackbarView: some View {
        if let configuration {
            VStack {
                SnackbarView(configuration: configuration, onCloseTap: {
                    dismiss()
                })
            }
            .transition(AnyTransition.opacity.combined(with: AnyTransition.move(edge: configuration.showFromTop ? .top : .bottom)))
        }
    }

    private var alignment: Alignment {
        guard let configuration else {
            return .center
        }

        return configuration.showFromTop ? .top : .bottom
    }

    private func scheduleDismissIfNecessary() {
        guard
            let configuration,
            let autoDismissTime = configuration.autoDismissTime,
            autoDismissTime > 0
        else {
            return
        }

        workItem?.cancel()

        let task = DispatchWorkItem {
            dismiss()
        }

        workItem = task
        DispatchQueue.main.asyncAfter(deadline: .now() + autoDismissTime, execute: task)
    }
}

public extension View {
    /// Helper extension to add a snackbar to a view, configured using a `SnackbarViewConfiguration`, that can be set to nil to hide the snackbar
    func snackbarView(configuration: Binding<SnackbarViewConfiguration?>) -> some View {
        self.modifier(SnackbarViewModifier(configuration: configuration))
    }
}

import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif

struct EndpointSelectionView: View {
    @State private var snackbarConfig: SnackbarViewConfiguration?
    @StateObject private var viewModel: EndpointSelectionViewModel

    init(viewModel: EndpointSelectionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.sizing.spacingSpacingMd) {
            DemoHelper.demoSectionHeader(title: "Choose Environment")

            RadioButtonList(
                values: viewModel.availableEndpointOptions,
                disabledValues: .constant(viewModel.disabledEndpointOptions),
                selectedValue: $viewModel.selectedEndpointOption,
                verticalSpacing: theme.sizing.spacingSpacingLg
            )

            TextInput(configuration: .init(text: $viewModel.customEndpointUrl))
                .disabled(viewModel.isInputDisabled)

            TextInput(
                configuration: .init(
                    text: $viewModel.bffApiKey,
                    placeholder: L10n.DebugMenu.Endpoint.ApiKey.placeholder,
                    isSecure: true
                )
            )
            .disabled(viewModel.isInputDisabled)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)

            HStack {
                Spacer()
                ThemedButton(
                    text: "Save and Restart",
                    isDisabled: .constant(viewModel.isSaveDisabled)
                ) { viewModel.didTapSave() }
                Spacer()
            }

            Spacer()
        }
        .padding(.horizontal, theme.sizing.spacingSpacingMd)
        .snackbarView(configuration: $snackbarConfig)
        .onChange(of: viewModel.urlError) { urlError in
            if let urlError {
                snackbarConfig = .init(
                    type: .error,
                    text: urlError.message,
                    showCloseButton: true,
                    icon: Icon.warning.image,
                    onDismiss: { viewModel.didDismissError() }
                )
            } else {
                snackbarConfig = nil
            }
        }
        .onChange(of: viewModel.shouldShowSuccess) { shouldShowSuccess in
            if shouldShowSuccess {
                snackbarConfig = .init(
                    type: .success,
                    text: "Done. The app will now restart automatically.",
                    showCloseButton: false,
                    showFromTop: true,
                    autoDismissTime: 4,
                    onDismiss: { viewModel.closeEndpointSelection() }
                )
            } else {
                snackbarConfig = nil
            }
        }
    }
}

private extension EndpointUrlError {
    var message: String {
        switch self {
        case .invalid:
            "Invalid endpoint URL"

        case .matchesPreset:
            L10n.DebugMenu.Endpoint.UrlError.matchesPreset
        }
    }
}

#if DEBUG
#Preview {
    EndpointSelectionView(
        viewModel: EndpointSelectionViewModel(
            apiEndpointService: MockApiEndpointService(),
            apiKeyService: MockBFFApiKeyService()
        ) { }
    )
}
#endif

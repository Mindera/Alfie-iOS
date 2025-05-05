import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif

struct EndpointSelectionView: View {
    @EnvironmentObject var coordinator: Coordinator
    @State private var snackbarConfig: SnackbarViewConfiguration?
    @StateObject private var viewModel: EndpointSelectionViewModel

    init(viewModel: EndpointSelectionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.space250) {
            DemoHelper.demoSectionHeader(title: "Choose Environment")

            RadioButtonList(
                values: viewModel.availableEndpointOptions,
                disabledValues: .constant(viewModel.disabledEndpointOptions),
                selectedValue: $viewModel.selectedEndpointOption,
                verticalSpacing: Spacing.space300
            )

            ThemedInput($viewModel.customEndpointUrl, isDisabled: .constant(viewModel.isInputDisabled))

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
        .padding(.horizontal, Spacing.space200)
        .snackbarView(configuration: $snackbarConfig)
        .onChange(of: viewModel.shouldShowUrlError) { shouldShowUrlError in
            if shouldShowUrlError {
                // swiftlint:disable:next trailing_closure
                snackbarConfig = .init(
                    type: .error,
                    text: "Invalid endpoint URL",
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
                // swiftlint:disable:next trailing_closure
                snackbarConfig = .init(
                    type: .success,
                    text: "Done. The app will now restart automatically.",
                    showCloseButton: false,
                    showFromTop: true,
                    autoDismissTime: 4,
                    onDismiss: { coordinator.closeEndpointSelection() }
                )
            } else {
                snackbarConfig = nil
            }
        }
    }
}

#if DEBUG
#Preview {
    EndpointSelectionView(viewModel: EndpointSelectionViewModel(apiEndpointService: MockApiEndpointService()))
}
#endif

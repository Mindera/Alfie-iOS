import Models
import StyleGuide
import SwiftUI

struct FeatureToggleView<ViewModel: FeatureToggleViewModelProtocol>: View {
    @ObservedObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        LazyVStack {
            ThemedToggleView(
                isOn: Binding(
                    get: { viewModel.isDebugConfigurationEnabled },
                    set: { _ in viewModel.toggleDebugConfiguration() }
                )
            ) {
                Text(LocalizableFeatureToggle.debugConfigurationEnabled)
                    .font(Font(theme.font.paragraph.bold.withSize(20)))
            }

            Divider()
            Spacer(minLength: Spacing.space200)

            if viewModel.isDebugConfigurationEnabled {
                ForEach(viewModel.features, id: \.feature) { feature, isEnabled in
                    ThemedToggleView(isOn: Binding(
                        get: { isEnabled },
                        set: { _ in viewModel.didUpdate(feature: feature) }
                    )) {
                        Text(theme.font.paragraph.normal(viewModel.localizedName(for: feature)))
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.space200)
        .onAppear {
            viewModel.viewDidAppear()
        }
    }
}

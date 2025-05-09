import Models
import SharedUI
import StyleGuide
import SwiftUI

struct FeatureToggleView<ViewModel: FeatureToggleViewModelProtocol>: View {
    @ObservedObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        LazyVStack {
            ThemedToggleView(isOn: $viewModel.isDebugConfigurationEnabled) {
                Text(L10n.FeatureToggle.DebugConfiguration.Option.title)
                    .font(Font(theme.font.paragraph.bold.withSize(20)))
            }

            Divider()
            Spacer(minLength: Spacing.space200)

            if viewModel.isDebugConfigurationEnabled {
                ForEach(viewModel.features, id: \.feature) { feature, _ in
                    ThemedToggleView(isOn: viewModel.binding(for: feature)) {
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

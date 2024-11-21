import Models
import StyleGuide
import SwiftUI

struct FeatureToggleView<ViewModel: FeatureToggleViewModelProtocol>: View {
	@ObservedObject private var viewModel: ViewModel

	init(viewModel: ViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		LazyVGrid(columns: [GridItem()]) {
			ForEach(viewModel.features.sorted { $0.key > $1.key }, id: \.key) { feature, isEnabled in
				HStack {
					ThemedToggleView(isOn: Binding(get: {
						isEnabled
					}, set: { _ in
						viewModel.didUpdate(feature: feature)
					})) {
						Text(
							theme
								.font
								.paragraph
								.normal(viewModel.description(for: feature))
						)
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

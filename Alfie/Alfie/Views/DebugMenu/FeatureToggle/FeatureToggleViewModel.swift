import FeatureToggles
import Models
import SwiftUI

final class FeatureToggleViewModel: FeatureToggleViewModelProtocol {
	@Published private(set) var features: [String: Bool] = [:]

	private let service: any ConfigurationServiceProtocol

	init(service: some ConfigurationServiceProtocol) {
		self.service = service
	}

	func viewDidAppear() {
		let featuresAsDict = ConfigurationKey.allCases.map { configuration in
			(configuration.rawValue, service.isFeatureEnabled(configuration))
		}

		self.features = Dictionary(uniqueKeysWithValues: featuresAsDict)
	}

	func didUpdate(feature: String) {
		guard
			let key = ConfigurationKey(rawValue: feature)
		else {
			return
		}

		let isEnabled = service.isFeatureEnabled(key)

		service.updateFeature(key, isEnabled: !isEnabled)

		self.features[feature] = service.isFeatureEnabled(key)
	}

	func description(for feature: String) -> LocalizedStringResource {
		LocalizableFeatureToggle.featureName(for: feature)
	}
}

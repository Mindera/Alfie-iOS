import Combine
import Models
import SwiftUI

final class FeatureToggleViewModel: FeatureToggleViewModelProtocol {
    @Published private(set) var features: [(feature: String, isEnabled: Bool)] = []
    @Published var isDebugConfigurationEnabled = false

    private let provider: any DebugConfigurationProviderProtocol
    private var store: Set<AnyCancellable> = []

    init(provider: some DebugConfigurationProviderProtocol) {
        self.provider = provider
    }

    func viewDidAppear() {
        self.features = ConfigurationKey.allCases.map { configuration in
            (configuration.rawValue, provider.bool(for: configuration) ?? true)
        }

        provider.isReadyPublisher
            .sink { isEnabled in
                self.isDebugConfigurationEnabled = isEnabled
            }
            .store(in: &store)
    }

    func didUpdate(feature: String) {
        guard let key = ConfigurationKey(rawValue: feature),
              let index = features.firstIndex(where: { $0.feature == key.rawValue }) else {
            return
        }

        let isEnabled = provider.bool(for: key) ?? true

        provider.updateFeature(key, isEnabled: !isEnabled)
        self.features[index] = (key.rawValue, !isEnabled)
    }

    func localizedName(for feature: String) -> LocalizedStringResource {
        guard let key = ConfigurationKey(rawValue: feature) else {
            return .init(stringLiteral: "")
        }

        return key.localizedName
    }

    func toggleDebugConfiguration() {
        provider.toggleAvailability()
    }
}

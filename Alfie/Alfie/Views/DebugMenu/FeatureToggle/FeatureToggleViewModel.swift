import Combine
import Models
import SwiftUI

final class FeatureToggleViewModel: FeatureToggleViewModelProtocol {
    @Published private(set) var features: [(feature: String, isEnabled: Bool)] = []
    @Published var isDebugConfigurationEnabled = false

    private let provider: any DebugConfigurationProviderProtocol
    private var isDebugConfigurationEnabledSubcription: AnyCancellable?

    init(provider: DebugConfigurationProviderProtocol) {
        self.provider = provider
    }

    func viewDidAppear() {
        features = ConfigurationKey.allCases.map { configuration in
            (configuration.rawValue, provider.bool(for: configuration) ?? true)
        }

        isDebugConfigurationEnabled = provider.isReady

        isDebugConfigurationEnabledSubcription = $isDebugConfigurationEnabled
            .dropFirst()
            .sink { _ in
                self.provider.toggleAvailability()
            }
    }

    func localizedName(for feature: String) -> String {
        guard let key = ConfigurationKey(rawValue: feature) else {
            return .init(stringLiteral: "")
        }

        return key.localizedName
    }

    func binding(for feature: String) -> Binding<Bool> {
        guard
            let key = ConfigurationKey(rawValue: feature),
            let index = features.firstIndex(where: { $0.feature == key.rawValue })
        else {
            return .constant(false)
        }

        return Binding(
            get: { self.features[index].isEnabled },
            set: { _ in self.updateState(for: feature) }
        )
    }
}

extension FeatureToggleViewModel {
    private func updateState(for feature: String) {
        guard
            let key = ConfigurationKey(rawValue: feature),
            let index = features.firstIndex(where: { $0.feature == key.rawValue })
        else {
            return
        }

        let isEnabled = provider.bool(for: key) ?? true

        provider.updateFeature(key, isEnabled: !isEnabled)
        features[index] = (key.rawValue, !isEnabled)
    }
}

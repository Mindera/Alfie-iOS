import SwiftUI

public protocol FeatureToggleViewModelProtocol: ObservableObject {
    var features: [(feature: String, isEnabled: Bool)] { get }
    var isDebugConfigurationEnabled: Bool { get set }

    func viewDidAppear()
    func localizedName(for feature: String) -> LocalizedStringResource
    func binding(for feature: String) -> Binding<Bool>
}

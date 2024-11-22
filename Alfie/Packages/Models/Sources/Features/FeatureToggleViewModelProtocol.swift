import SwiftUI

public protocol FeatureToggleViewModelProtocol: ObservableObject {
    var features: [(feature: String, isEnabled: Bool)] { get }
    var isDebugConfigurationEnabled: Bool { get }

	func viewDidAppear()
	func didUpdate(feature: String)
	func localizedName(for feature: String) -> LocalizedStringResource
    func toggleDebugConfiguration()
}

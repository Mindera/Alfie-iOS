import SwiftUI

public protocol FeatureToggleViewModelProtocol: ObservableObject {
	var features: [String: Bool] { get }

	func viewDidAppear()
	func didUpdate(feature: String)
	func description(for feature: String) -> LocalizedStringResource
}

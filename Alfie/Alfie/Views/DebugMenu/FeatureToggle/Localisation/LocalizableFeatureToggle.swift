import Foundation

struct LocalizableFeatureToggle: LocalizableProtocol {
	@LocalizableResource<Self>(.title) static var title

	static func featureName(for feature: String, locale: Locale = .current) -> LocalizedStringResource {
		.init(
			String.LocalizationValue(stringLiteral: "Key\(feature)Feature"),
			table: tableName,
			locale: locale
		)
	}

	enum Keys: String, LocalizableKeyProtocol {
		case title = "KeyFeatureToggle"
	}
}

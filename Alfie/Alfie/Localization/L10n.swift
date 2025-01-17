import Foundation

enum L10n {
    // MARK: - Internal Properties

    static var tableName: String {
        String(describing: Self.self)
    }

    // MARK: - Resource

    @propertyWrapper
    struct Resource {
        var wrappedValue: LocalizedStringResource

        /// Initialise a LocalizedStringResource from a given table.
        /// - Parameters:
        ///   - key: the static key that identifies the resource
        ///   - defaultValue: value returned when the key does not exist
        ///   - arguments: values to format the string if it has placeholders
        init(
            _ key: L10n.Keys,
            defaultValue: String = "",
            arguments: CVarArg...
        ) {
            let rawValue = key.rawValue

            // Create the localized string resource
            let resource = LocalizedStringResource(
                String.LocalizationValue(stringLiteral: rawValue),
                table: tableName
            )

            // Check if the localized string exists
            var localizedString = String(localized: resource)
            if localizedString == rawValue {
                localizedString = defaultValue
            }

            // Format the string with arguments if provided
            if !arguments.isEmpty {
                localizedString = String(format: localizedString, arguments: arguments)
            }

            self.wrappedValue = LocalizedStringResource(stringLiteral: localizedString)
        }

        var projectedValue: String {
            String(localized: wrappedValue)
        }
    }
}

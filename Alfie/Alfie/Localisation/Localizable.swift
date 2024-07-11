import Foundation

@propertyWrapper
struct LocalizableResource<L: LocalizableProtocol> {
    var wrappedValue: LocalizedStringResource

    /// Initialise a LocalizedStringResource from a given table.
    /// - Parameters:
    ///   - key: the static key that identifies the resource
    ///   - defaultValue: value returned when the key does not exist
    init(_ key: L.Keys, defaultValue: String = "") {
        let resource = LocalizedStringResource(String.LocalizationValue(stringLiteral: key.rawValue), table: L.tableName)
        guard String(localized: resource) != key.rawValue else {
            self.wrappedValue = LocalizedStringResource(stringLiteral: defaultValue)
            return
        }
        self.wrappedValue = resource
    }

    var projectedValue: String {
        String(localized: wrappedValue)
    }
}

import BFFGraphApi
import Models

// MARK: Dictionary Attributes

extension Collection where Element == AttributesFragment {
    public func convertToAttributeCollection() -> AttributeCollection {
        reduce(into: AttributeCollection()) { result, item in
            result[item.key] = item.value
        }
    }
}

import Foundation

/// Persistence boundary for the bag.
///
/// Speaks the domain language (`SelectedProduct`). Implementations
/// in the infrastructure layer are responsible for any DTO mapping.
public protocol BagStoreProtocol {
    func load() -> [SelectedProduct]
    func save(_ products: [SelectedProduct])
}

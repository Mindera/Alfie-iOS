import Foundation

/// Persistence boundary for the wishlist.
///
/// Speaks the domain language (`SelectedProduct`). Implementations
/// in the infrastructure layer are responsible for any DTO mapping.
public protocol WishlistStoreProtocol {
    func load() -> [SelectedProduct]
    func save(_ products: [SelectedProduct])
}

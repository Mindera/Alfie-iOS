import Foundation

/// Centralized seed anchors for integration assertions. `collectionHandle` is one of the real Shopify
/// handles the app already trusts in `BFFClientService.getHeaderNav`; `sortLowToHigh` is the app-level
/// sort token (`BFFGraphAPI.ProductSortEnum.from(sortOption:)` maps it to `PRICE_ASC`). Kept in one
/// place so a seed-data change is a single edit.
enum IntegrationSeed {
    static let collectionHandle = "women"
    static let searchTerm = "shirt"
    static let sortLowToHigh = "LOW_TO_HIGH"
}

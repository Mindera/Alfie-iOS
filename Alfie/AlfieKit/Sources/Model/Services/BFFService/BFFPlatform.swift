import Foundation

/// The commerce backend the BFF resolves a product against.
///
/// This is a **predefined, app-level** choice — Alfie targets a single commerce platform per build.
/// It is deliberately NOT derived per-product: the BFF's `OmniProduct` carries no platform field, so
/// the value cannot come from a tapped product. Every `productDetails` request sends ``predefined``.
/// To change the platform the app talks to, change that one constant.
public enum BFFPlatform: String {
    case shopify
    case bigCommerce = "bigcommerce"

    /// The predefined platform sent on every `productDetails` request.
    public static let predefined: BFFPlatform = .shopify
}

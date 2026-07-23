import Foundation

/// The commerce backend the BFF resolves a request against.
///
/// This is an **app-level** choice — Alfie targets a single commerce platform per build. It is
/// deliberately NOT derived per-product: the BFF's `OmniProduct` carries no platform field, so the
/// value cannot come from a tapped product. Every BFF request sends ``predefined``.
public enum BFFPlatform: String, CaseIterable {
    case shopify
    case bigCommerce = "bigcommerce"

    /// Platform sent on every BFF request. Release builds always use `.shopify`; DEBUG builds honor
    /// the debug-menu override (see ``BFFPlatformDebugStore``).
    public static var predefined: BFFPlatform {
        #if DEBUG
        BFFPlatformDebugStore.selected
        #else
        .shopify
        #endif
    }
}

/// Persists a debug-menu override for ``BFFPlatform/predefined``. The override only takes effect in
/// DEBUG builds (see ``BFFPlatform/predefined``); the store itself compiles everywhere so the debug
/// UI has a single home to read/write. Applies to the next request — no app restart needed.
public enum BFFPlatformDebugStore {
    public static let userDefaultsKey = "com.alfie.debug.bffPlatform"

    public static var selected: BFFPlatform {
        get {
            UserDefaults.standard.string(forKey: userDefaultsKey)
                .flatMap(BFFPlatform.init(rawValue:)) ?? .shopify
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: userDefaultsKey)
        }
    }
}

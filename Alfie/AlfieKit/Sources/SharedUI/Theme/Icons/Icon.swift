import Foundation
import struct SwiftUI.Image
import class UIKit.UIImage

/// The Alfie icon set. In-scope icons (Figma "Arrows & System" + "E-commerce") resolve to bundled
/// vector assets in `Icons.xcassets`; the remaining cases have no Figma equivalent and fall back to
/// SF Symbols. Asset raw values are the Figma-derived kebab-case asset names; fallback raw values are
/// SF Symbol names. See `Docs/Iconography.md` for the Figma→repo mapping and re-export process.
public enum Icon: String, IconRepresentable, CaseIterable {
    // MARK: Asset-backed (bundled Figma artwork)
    case accountFill = "account-fill"
    case arrowRight = "forward"
    case back
    case bag
    case bagFill = "bag-fill"
    case bell = "notification"
    case checkmark = "check"
    case chevronDown = "chevron-down"
    case chevronLeft = "chevron-left"
    case chevronRight = "chevron-right"
    case chevronUp = "chevron-up"
    case close
    case closeCircleFill = "clear"
    case creditCard = "credit-card"
    case download
    case edit = "pencil"
    case ellipsis = "more"
    case fastDelivery = "fast-delivery"
    case filter = "refine"
    case gift
    case grid = "grid-2"
    case grid1Fill = "grid-1-fill"
    case grid2Fill = "grid-2-fill"
    case hamburguerMenu = "menu"
    case heart = "wishlist"
    case heartFill = "wishlist-fill"
    case help
    case home
    case homeFill = "home-fill"
    case info
    case list = "menu-alt"
    case listplp = "grid-1"
    case logOut = "exit"
    case minus
    case orderReturn = "return"
    case package
    case plus = "add"
    case profileID = "profile-id"
    case refresh = "loading"
    case refund
    case reload
    case search
    case settings
    case share
    case star
    case starFill = "star-fill"
    case starHalfFill = "star-half-fill"
    case trash = "delete"
    case user = "account"
    case warning = "alert-fill"

    // MARK: SF Symbol fallbacks (no in-scope Figma equivalent)
    case aCircle = "a.circle"
    case arrowLeft = "arrow.left"
    case chartDownTrend = "chart.line.downtrend.xyaxis"
    case chartUpTrend = "chart.line.uptrend.xyaxis"
    case chat2 = "note.text"
    case location = "mappin.circle.fill"
    case logIn = "ipad.and.arrow.forward"
    case rewards = "rosette"
    case store = "storefront"
    case zCircle = "z.circle"
}

public extension Icon {
    /// Asset-backed icons render from the bundled catalog (template intent set in the asset);
    /// fallbacks render from SF Symbols.
    var image: Image {
        usesSystemSymbol ? Image(systemName: rawValue) : Image(assetName, bundle: bundle)
    }

    var uiImage: UIImage {
        if usesSystemSymbol {
            return UIImage(systemName: rawValue) ?? UIImage()
        }
        return UIImage(named: assetName, in: bundle, with: nil) ?? UIImage()
    }
}

extension Icon {
    /// The bundled asset name. Defaults to `rawValue`; aliased where two cases share one glyph
    /// (raw values must stay unique, but they can point at the same artwork).
    var assetName: String {
        switch self {
        case .info:
            return "help"
        case .reload:
            return "loading"
        default:
            return rawValue
        }
    }
}

extension Icon {
    /// The cases with no in-scope Figma artwork; everything else resolves to a bundled asset.
    static let systemSymbolFallbacks: Set<Icon> = [
        .aCircle, .arrowLeft, .chartDownTrend, .chartUpTrend, .chat2,
        .location, .logIn, .rewards, .store, .zCircle,
    ]

    var usesSystemSymbol: Bool {
        Self.systemSymbolFallbacks.contains(self)
    }
}

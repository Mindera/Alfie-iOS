import Foundation
import struct SwiftUI.Image
import class UIKit.UIImage

/// The Alfie icon set. Every case resolves to a bundled vector asset in `Icons.xcassets`, exported
/// from the Figma Iconography page (the "Arrows & System", "E-commerce" and "SF Symbol - iOS"
/// sections). Raw values are the kebab-case asset names, except aliased cases (`reload`) that keep a
/// unique raw value and resolve via `assetName`. See `Docs/Iconography.md` for the mapping + re-export.
public enum Icon: String, IconRepresentable, CaseIterable {
    case aCircle = "a-circle"
    case accountFill = "account-fill"
    case arrowLeft = "arrow-left"
    case arrowRight = "forward"
    case back
    case bag
    case bagFill = "bag-fill"
    case bell = "notification"
    case chartDownTrend = "chart-line-downtrend-xyaxis"
    case chartUpTrend = "chart-line-uptrend-xyaxis"
    case chat2 = "note-text"
    case checkmark = "check"
    case chevronDown = "chevron-down"
    case chevronLeft = "chevron-left"
    case chevronRight = "chevron-right"
    case chevronUp = "chevron-up"
    case clear
    case close
    case closeCircleFill = "xmark-circle-fill"
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
    case info = "info-circle"
    case list = "list-bullet"
    case listplp = "grid-1"
    case location = "mappin-circle-fill"
    case logIn = "ipad-and-arrow-forward"
    case logOut = "exit"
    case menuAlt = "menu-alt"
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
    case store = "storefront"
    case trash = "delete"
    case user = "account"
    case warning = "alert-fill"
    case zCircle = "z-circle"
}

public extension Icon {
    /// Icons render from the bundled catalog (template intent is set on each asset).
    var image: Image {
        Image(assetName, bundle: bundle)
    }

    var uiImage: UIImage {
        UIImage(named: assetName, in: bundle, compatibleWith: nil) ?? UIImage()
    }
}

extension Icon {
    /// The bundled asset name. Defaults to `rawValue`; aliased where two cases share one glyph
    /// (raw values must stay unique, but they can point at the same artwork).
    var assetName: String {
        switch self {
        case .reload:
            return "loading"
        default:
            return rawValue
        }
    }
}

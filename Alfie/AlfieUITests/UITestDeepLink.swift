import Foundation

enum UITestDeepLink {
    case product(handle: String)

    var url: URL? {
        switch self {
        case .product(let handle):
            return URL(string: "alfie://alfie.target/product/\(handle)")
        }
    }
}

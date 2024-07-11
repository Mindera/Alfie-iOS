import UIKit

public extension UIApplication {
    var keyWindows: [UIWindow]? {
        connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .filter { $0.isKeyWindow }
    }
}

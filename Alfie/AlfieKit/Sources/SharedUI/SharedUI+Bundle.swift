import Foundation

final class BundleToken {}

public extension Bundle {
    static var sharedUI: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: BundleToken.self)
        #endif
    }
}

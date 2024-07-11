import Foundation
import struct SwiftUI.Image
import class UIKit.UIImage

public protocol IconRepresentable: RawRepresentable {
    var literalName: String { get }
    var bundle: Bundle { get }
}

public extension RawRepresentable where Self: IconRepresentable, RawValue == String {
    var literalName: String {
        rawValue
    }

    var image: Image {
        Image(systemName: rawValue)
    }

    var uiImage: UIImage {
        .init(named: rawValue, in: bundle, with: nil) ?? UIImage()
    }

    var bundle: Bundle {
        .module
    }
}

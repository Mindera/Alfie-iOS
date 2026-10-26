import UIKit

extension UIImage {
    public static func solid(_ colour: UIColor, size: CGSize = .init(width: 3, height: 4)) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { context in
            colour.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}

import Foundation

public struct VerticalProductCardConfiguration {
    public enum Size {
        case small
        case medium
        case large
    }

    public enum CardIntrinsicSize {
        case fixed(size: CGFloat)
        case flexible

        public var value: CGFloat? {
            guard case .fixed(let size) = self else {
                return nil
            }
            return size
        }
    }

    public let size: Size
    public let hidePrice: Bool
    public let hideAction: Bool

    public init(
        size: Size,
        hidePrice: Bool = false,
        hideAction: Bool = false
    ) {
        self.size = size
        self.hidePrice = hidePrice
        self.hideAction = hideAction
    }
}

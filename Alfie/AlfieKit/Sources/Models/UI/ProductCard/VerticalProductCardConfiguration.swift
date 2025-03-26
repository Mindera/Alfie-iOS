import Foundation

public struct VerticalProductCardConfiguration {
    public enum Size {
        case small
        case medium
        case large
    }

    public enum ActionType {
        case wishlist
        case remove
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
    public let hideColor: Bool
    public let hideSize: Bool
    public let hidePrice: Bool
    public let hideAction: Bool
    public let actionType: ActionType

    public init(
        size: Size,
        hideColor: Bool = false,
        hideSize: Bool = false,
        hidePrice: Bool = false,
        hideAction: Bool = false,
        actionType: ActionType = .wishlist
    ) {
        self.size = size
        self.hideColor = hideColor
        self.hideSize = hideSize
        self.hidePrice = hidePrice
        self.hideAction = hideAction
        self.actionType = actionType
    }
}

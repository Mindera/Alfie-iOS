import SwiftUI

public extension Animation {
    static let emphasized = Animation.linear(duration: 0.5)
    static let emphasizedAccelerate = Animation.easeIn(duration: 0.2)
    static let emphasizedDecelerate = Animation.easeOut(duration: 0.4)

    static let standard = Animation.linear(duration: 0.3)
    static let standardAccelerate = Animation.easeIn(duration: 0.2)
    static let standardDecelerate = Animation.easeOut(duration: 0.25)
}

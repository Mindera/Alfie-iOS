import SwiftUI

internal struct BadgeHelper {
    @Binding private var badgeValue: Int?
    private let hideOnZero: Bool

    var hideBadge: Bool {
        guard let badgeValue else {
            return true
        }

        return badgeValue == 0 && hideOnZero
    }

    var isIndicator: Bool {
        guard let badgeValue else {
            return false
        }

        return badgeValue == 0 && !hideOnZero
    }

    var badgeLabel: String {
        guard let badgeValue, !isIndicator, !hideBadge else {
            return ""
        }

        return badgeValue > Constants.maxVal ? "\(Constants.maxVal)+" : "\(badgeValue)"
    }

    private enum Constants {
        static let maxVal = 99
    }

    internal init(badgeValue: Binding<Int?>, hideOnZero: Bool) {
        self._badgeValue = badgeValue
        self.hideOnZero = hideOnZero
    }
}

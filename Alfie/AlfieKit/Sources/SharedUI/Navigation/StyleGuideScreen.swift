import Foundation
import Navigation
import SwiftUI

public enum StyleGuideScreen: ScreenProtocol, Equatable {
    case accordion
    case badges
    case buttons
    case checkboxes
    case color
    case colorSwatches
    case cornerRadius
    case datePicker
    case demo
    case dividers
    case icons
    case inputs
    case loading
    case motion
    case pageControl
    case progressBar
    case radioButtonsList
    case shadows
    case sizingSwaches
    case skeleton
    case snackbars
    case spacings
    case tags
    case toggle
    case toolbar
    case typography

    public var id: StyleGuideScreen {
        self
    }
}

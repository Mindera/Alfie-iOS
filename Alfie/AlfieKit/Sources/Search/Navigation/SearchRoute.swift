import Foundation
import SwiftUI

public enum SearchRoute: Hashable {
    case search
    case searchIntent(SearchIntent)
}

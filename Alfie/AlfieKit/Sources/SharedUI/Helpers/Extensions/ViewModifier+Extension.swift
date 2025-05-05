import SwiftUI

public extension ViewModifier {
    var theme: ThemeProviderProtocol { ThemeProvider.shared }
}

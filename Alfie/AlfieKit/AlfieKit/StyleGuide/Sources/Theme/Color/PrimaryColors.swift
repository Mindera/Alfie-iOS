import SwiftUI
import UIKit

public protocol PrimaryColorsProtocol {
    var mono900: Color { get }
    var mono800: Color { get }
    var mono700: Color { get }
    var mono600: Color { get }
    var mono500: Color { get }
    var mono400: Color { get }
    var mono300: Color { get }
    var mono200: Color { get }
    var mono100: Color { get }
    var mono050: Color { get }

    var black: Color { get }
    var white: Color { get }
}

struct PrimaryColors: PrimaryColorsProtocol {
    private static let bundle = Bundle.module

    let mono900 = Color("Mono900", bundle: bundle)
    let mono800 = Color("Mono800", bundle: bundle)
    let mono700 = Color("Mono700", bundle: bundle)
    let mono600 = Color("Mono600", bundle: bundle)
    let mono500 = Color("Mono500", bundle: bundle)
    let mono400 = Color("Mono400", bundle: bundle)
    let mono300 = Color("Mono300", bundle: bundle)
    let mono200 = Color("Mono200", bundle: bundle)
    let mono100 = Color("Mono100", bundle: bundle)
    let mono050 = Color("Mono050", bundle: bundle)

    let black = Color("Black", bundle: bundle)
    let white = Color("White", bundle: bundle)
}

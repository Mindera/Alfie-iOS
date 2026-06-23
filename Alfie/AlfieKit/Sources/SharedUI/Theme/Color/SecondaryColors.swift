import SwiftUI

public protocol SecondaryColorsProtocol {
    var blue900: Color { get }
    var blue800: Color { get }
    var blue700: Color { get }
    var blue600: Color { get }
    var blue500: Color { get }
    var blue400: Color { get }
    var blue300: Color { get }
    var blue200: Color { get }
    var blue100: Color { get }
    var blue050: Color { get }

    var yellow500: Color { get }
    var yellow400: Color { get }
    var yellow300: Color { get }
    var yellow200: Color { get }
    var yellow100: Color { get }
    var yellow050: Color { get }

    var orange500: Color { get }
    var orange400: Color { get }
    var orange300: Color { get }
    var orange200: Color { get }
    var orange100: Color { get }
    var orange050: Color { get }
}

struct SecondaryColors: SecondaryColorsProtocol {
    private static let bundle = Bundle.module

    let blue900 = Color("Blue900", bundle: bundle)
    let blue800 = Color("Blue800", bundle: bundle)
    let blue700 = Color("Blue700", bundle: bundle)
    let blue600 = Color("Blue600", bundle: bundle)
    let blue500 = Color("Blue500", bundle: bundle)
    let blue400 = Color("Blue400", bundle: bundle)
    let blue300 = Color("Blue300", bundle: bundle)
    let blue200 = Color("Blue200", bundle: bundle)
    let blue100 = Color("Blue100", bundle: bundle)
    let blue050 = Color("Blue050", bundle: bundle)

    let yellow500 = Color("Yellow500", bundle: bundle)
    let yellow400 = Color("Yellow400", bundle: bundle)
    let yellow300 = Color("Yellow300", bundle: bundle)
    let yellow200 = Color("Yellow200", bundle: bundle)
    let yellow100 = Color("Yellow100", bundle: bundle)
    let yellow050 = Color("Yellow050", bundle: bundle)

    let orange500 = Color("Orange500", bundle: bundle)
    let orange400 = Color("Orange400", bundle: bundle)
    let orange300 = Color("Orange300", bundle: bundle)
    let orange200 = Color("Orange200", bundle: bundle)
    let orange100 = Color("Orange100", bundle: bundle)
    let orange050 = Color("Orange050", bundle: bundle)
}

import SwiftUI

public protocol SecondaryColorsProtocol {
    var green900: Color { get }
    var green800: Color { get }
    var green700: Color { get }
    var green600: Color { get }
    var green500: Color { get }
    var green400: Color { get }
    var green300: Color { get }
    var green200: Color { get }
    var green100: Color { get }
    var green050: Color { get }

    var red900: Color { get }
    var red800: Color { get }
    var red700: Color { get }
    var red600: Color { get }
    var red500: Color { get }
    var red400: Color { get }
    var red300: Color { get }
    var red200: Color { get }
    var red100: Color { get }
    var red050: Color { get }

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

    let green900 = Color("Green900", bundle: bundle)
    let green800 = Color("Green800", bundle: bundle)
    let green700 = Color("Green700", bundle: bundle)
    let green600 = Color("Green600", bundle: bundle)
    let green500 = Color("Green500", bundle: bundle)
    let green400 = Color("Green400", bundle: bundle)
    let green300 = Color("Green300", bundle: bundle)
    let green200 = Color("Green200", bundle: bundle)
    let green100 = Color("Green100", bundle: bundle)
    let green050 = Color("Green050", bundle: bundle)

    let red900 = Color("Red900", bundle: bundle)
    let red800 = Color("Red800", bundle: bundle)
    let red700 = Color("Red700", bundle: bundle)
    let red600 = Color("Red600", bundle: bundle)
    let red500 = Color("Red500", bundle: bundle)
    let red400 = Color("Red400", bundle: bundle)
    let red300 = Color("Red300", bundle: bundle)
    let red200 = Color("Red200", bundle: bundle)
    let red100 = Color("Red100", bundle: bundle)
    let red050 = Color("Red050", bundle: bundle)

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

import Foundation

extension L10n {
    static func tr(
        _ table: String,
        _ key: StaticString,
        _ args: CVarArg...
    ) -> String {
        String(
            localized: key,
            defaultValue: defaultValue(key, args),
            table: table,
            bundle: BundleToken.bundle,
            locale: Locale.current
        )
    }

    private static func defaultValue(
        _ key: StaticString,
        _ args: CVarArg...
    ) -> String.LocalizationValue {
        var stringInterpolation = String.LocalizationValue.StringInterpolation(
            literalCapacity: 0,
            interpolationCount: args.count
        )
        args.forEach { stringInterpolation.appendInterpolation(arg: $0) }
        return .init(stringInterpolation: stringInterpolation)
    }
}

private extension String.LocalizationValue.StringInterpolation {
    mutating func appendInterpolation(arg: CVarArg) {
        switch arg {
        case let arg as String:
            appendInterpolation(arg)

        case let arg as Int:
            appendInterpolation(arg)

        case let arg as UInt:
            appendInterpolation(arg)

        case let arg as Double:
            appendInterpolation(arg)

        case let arg as Float:
            appendInterpolation(arg)

        default:
            return
        }
    }
}

// swiftlint:disable convenience_type
private final class BundleToken {
    static let bundle: Bundle = {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: BundleToken.self)
        #endif
    }()
}
// swiftlint:enable convenience_type

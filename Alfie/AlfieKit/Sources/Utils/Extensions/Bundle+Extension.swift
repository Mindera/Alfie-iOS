import Foundation

extension Bundle {
    public static func filename(fileID: StaticString = #fileID) -> String {
        "\(fileID)".components(separatedBy: "/").last ?? ""
    }

    private static let bundleShortVersionKey = "CFBundleShortVersionString"

    public var appVersion: String {
        guard
            let dictionary = infoDictionary,
            let version = dictionary[Bundle.bundleShortVersionKey] as? String
        else {
            assertionFailure("Unable to access infoDictionary from Bundle")
            return ""
        }

        return version
    }
}

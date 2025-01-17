import Foundation

extension HTTPURLResponse {
    public var isError: Bool {
        statusCode >= 400
    }
}

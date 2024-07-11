import Foundation

enum NetworkError: Error {
    case notFound
    case genericClient
    case genericServer
    case unknown

    static func fromResponse(_ response: URLResponse) -> NetworkError? {
        guard let response = response as? HTTPURLResponse else {
            return .genericServer
        }

        if response.statusCode == 404 {
            return .notFound
        }

        switch response.statusCode {
            case 400 ..< 500:
                return .genericClient
            default:
                return nil
        }
    }
}

public protocol NetworkClientProtocol {
    func getData<T: Decodable>(from url: URL, authenticationToken: String?) async throws -> T
    func sendData<T: Encodable>(_ data: T, to url: URL, authenticationToken: String?) async throws
}

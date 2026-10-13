import AlicerceLogging
import Foundation
import Utils

public final class NetworkClient: NetworkClientProtocol {
    private let logRequests: Bool
    private let logResponses: Bool
    private let log: Logger

    public init(logRequests: Bool = true, logResponses: Bool = true, log: Logger) {
        self.logRequests = logRequests
        self.logResponses = logResponses
        self.log = log
    }

    // MARK: - NetworkClientProtocol

    public func getData<T: Decodable>(from url: URL, authenticationToken: String?) async throws -> T {
        var request = URLRequest(url: url)
        if let authenticationToken {
            request.setValue(
                BearerAuthorization.headerValue(token: authenticationToken),
                forHTTPHeaderField: BearerAuthorization.headerName
            )
        }

        if logRequests {
            log.debug("[REST] Outgoing GET request: \(request)")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let response = response as? HTTPURLResponse, !response.isError else {
            throw NetworkError.fromResponse(response) ?? .genericClient
        }

        if logResponses {
            log.debug("[REST] HTTP Response: \(response)")

            if let stringData = String(data: data, encoding: .utf8) {
                log.verbose("[REST] Response Data: \(stringData)")
            } else {
                log.error("[REST] Could not convert response data to string")
            }
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    public func sendData<T: Encodable>(_ data: T, to url: URL, authenticationToken: String?) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let authenticationToken {
            request.setValue(
                BearerAuthorization.headerValue(token: authenticationToken),
                forHTTPHeaderField: BearerAuthorization.headerName
            )
        }

        if logRequests {
            log.debug("[REST] Outgoing POST request: \(request)")
        }

        let encodedData = try JSONEncoder().encode(data)
        let (_, response) = try await URLSession.shared.upload(for: request, from: encodedData)

        if logResponses {
            log.debug("[REST] HTTP Response: \(response)")
        }

        guard let response = response as? HTTPURLResponse, !response.isError else {
            throw NetworkError.fromResponse(response) ?? .genericClient
        }
    }
}

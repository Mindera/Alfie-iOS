import Foundation

public final class NetworkClient: NetworkClientProtocol {
    private enum Headers: String {
        case authorization = "Autorization"
    }

    private let logRequests: Bool
    private let logResponses: Bool

    public init(logRequests: Bool = true, logResponses: Bool = true) {
        self.logRequests = logRequests
        self.logResponses = logResponses
    }

    // MARK: - NetworkClientProtocol

    public func getData<T: Decodable>(from url: URL, authenticationToken: String?) async throws -> T {
        var request = URLRequest(url: url)
        if let authenticationToken {
            request.setValue(
                authorizationHeader(token: authenticationToken),
                forHTTPHeaderField: Headers.authorization.rawValue
            )
        }

        if logRequests {
            log("[REST] Outgoing GET request: \(request)")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let response = response as? HTTPURLResponse, !response.isError else {
            throw NetworkError.fromResponse(response) ?? .genericClient
        }

        if logResponses {
            log("[REST] HTTP Response: \(response)")

            if let stringData = String(data: data, encoding: .utf8) {
                log("[REST] Response Data: \(stringData)")
            } else {
                logError("[REST] Could not convert response data to string")
            }
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    public func sendData<T: Encodable>(_ data: T, to url: URL, authenticationToken: String?) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let authenticationToken {
            request.setValue(
                authorizationHeader(token: authenticationToken),
                forHTTPHeaderField: Headers.authorization.rawValue
            )
        }

        if logRequests {
            log("[REST] Outgoing POST request: \(request)")
        }

        let encodedData = try JSONEncoder().encode(data)
        let (_, response) = try await URLSession.shared.upload(for: request, from: encodedData)

        if logResponses {
            log("[REST] HTTP Response: \(response)")
        }

        guard let response = response as? HTTPURLResponse, !response.isError else {
            throw NetworkError.fromResponse(response) ?? .genericClient
        }
    }

    // MARK: - Private

    private func authorizationHeader(token: String) -> String {
        "Bearer \(token)"
    }
}
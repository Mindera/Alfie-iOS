public enum BearerAuthorization {
    public static let headerName = "Authorization"

    public static func headerValue(token: String) -> String {
        "Bearer \(token)"
    }
}

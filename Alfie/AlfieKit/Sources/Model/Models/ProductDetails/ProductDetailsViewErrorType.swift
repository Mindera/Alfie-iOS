import Foundation

public enum ProductDetailsViewErrorType: Error, CaseIterable {
    case generic
    case noInternet
    case notFound
}

import Foundation

public enum PriceType {
    case `default`(price: String)
    case sale(fullPrice: String, finalPrice: String)
    case range(lowerBound: String, upperBound: String, separator: String)
}

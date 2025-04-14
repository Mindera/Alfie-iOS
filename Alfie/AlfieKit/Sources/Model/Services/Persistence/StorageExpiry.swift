import Foundation

public enum StorageExpiry {
    case never
    case timeInterval(value: TimeInterval)
}

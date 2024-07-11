import Foundation

extension Dictionary {
    public func has(key: Key) -> Bool {
        self.index(forKey: key) != nil
    }
}

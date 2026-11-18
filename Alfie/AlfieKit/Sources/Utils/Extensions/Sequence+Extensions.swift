import Foundation

public extension Sequence {
    func uniqued<Key: Hashable>(on key: (Element) throws -> Key) rethrows -> [Element] {
        var seen = Set<Key>()
        return try filter { seen.insert(try key($0)).inserted }
    }
}

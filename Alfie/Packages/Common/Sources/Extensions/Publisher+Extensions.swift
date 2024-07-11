import Combine

public extension Publisher where Failure == Never {
    /// Assign published values without strongly capturing the passed `object`
    func assignWeakly<T: AnyObject>(to keyPath: ReferenceWritableKeyPath<T, Output>, on object: T) -> AnyCancellable {
        sink { [weak object] in
            object?[keyPath: keyPath] = $0
        }
    }

    /// Assign weakly published value of type Output to a property of type Output? of the provided object
    func assignWeakly<T: AnyObject>(to keyPath: ReferenceWritableKeyPath<T, Output?>, on object: T) -> AnyCancellable {
        map { Optional($0) }.assignWeakly(to: keyPath, on: object)
    }
}

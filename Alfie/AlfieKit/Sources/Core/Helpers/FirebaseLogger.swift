import AlicerceLogging
import FirebaseCore
import FirebaseCrashlytics
import Foundation

public class FirebaseLogDestination: MetadataLogDestination {
    public typealias MetadataKey = Log.NoMetadataKey
    
    public var minLevel: AlicerceLogging.Log.Level
    
    public init(minLevel: Log.Level = .verbose) {
        self.minLevel = minLevel
    }
    
    public func write(
        item: Log.Item,
        onFailure: @escaping (any Error) -> Void
    ) {
        Crashlytics.crashlytics().log(item.message)
    }
    
    public func setMetadata(
        _ metadata: [Log.NoMetadataKey: Any],
        onFailure: @escaping (any Error) -> Void
    ) { }
    
    public func removeMetadata(
        forKeys keys: [Log.NoMetadataKey],
        onFailure: @escaping (any Error) -> Void
    ) { }
}

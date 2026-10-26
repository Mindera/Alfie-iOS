import Nuke
import SwiftUI

private struct ImagePipelineKey: EnvironmentKey {
    static var defaultValue: ImagePipeline { .shared }
}

public extension EnvironmentValues {
    /// Read once when a `RemoteImage` appears; changing it later doesn't reload images already on screen.
    var imagePipeline: ImagePipeline {
        get { self[ImagePipelineKey.self] }
        set { self[ImagePipelineKey.self] = newValue }
    }
}

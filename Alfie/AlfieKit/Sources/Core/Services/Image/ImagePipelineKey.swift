import Nuke
import SwiftUI

private struct ImagePipelineKey: EnvironmentKey {
    static var defaultValue: ImagePipeline { .shared }
}

public extension EnvironmentValues {
    var imagePipeline: ImagePipeline {
        get { self[ImagePipelineKey.self] }
        set { self[ImagePipelineKey.self] = newValue }
    }
}

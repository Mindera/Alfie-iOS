// swift-tools-version:5.9
import PackageDescription

// Standalone Alfie code (QR) generator for demo swing tags (issue #135). Intentionally OUTSIDE the
// AlfieKit graph, like DesignTokenGen: the app/CI never compile or run this, and nothing it emits
// is committed. macOS-only — it leans on CoreImage/ImageIO to render and to verify what it rendered.
let package = Package(
    name: "AlfieCodeGen",
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(
            name: "AlfieCodeGen",
            dependencies: ["AlfieCodeGenCore"]
        ),
        .target(
            name: "AlfieCodeGenCore"
        ),
        .testTarget(
            name: "AlfieCodeGenCoreTests",
            dependencies: ["AlfieCodeGenCore"]
        ),
    ]
)

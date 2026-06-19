// swift-tools-version:5.9
import PackageDescription

// Standalone design-token code generator (ALFMOB-272). Intentionally OUTSIDE the AlfieKit
// graph: the app/CI never compile or run this — generated Swift is committed. Foundation-only.
let package = Package(
    name: "DesignTokenGen",
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(
            name: "DesignTokenGen",
            dependencies: ["DesignTokenGenCore"]
        ),
        .target(
            name: "DesignTokenGenCore"
        ),
        .testTarget(
            name: "DesignTokenGenCoreTests",
            dependencies: ["DesignTokenGenCore"],
            resources: [.copy("Fixtures")]
        ),
    ]
)

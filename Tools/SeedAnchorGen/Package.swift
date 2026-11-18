// swift-tools-version:5.9
import PackageDescription

// Standalone seed-anchor code generator (ALFMOB-567). Intentionally OUTSIDE the AlfieKit
// graph: the app/CI never compile or run this — generated Swift is committed. Foundation-only.
let package = Package(
    name: "SeedAnchorGen",
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(
            name: "SeedAnchorGen",
            dependencies: ["SeedAnchorGenCore"]
        ),
        .target(
            name: "SeedAnchorGenCore"
        ),
        .testTarget(
            name: "SeedAnchorGenCoreTests",
            dependencies: ["SeedAnchorGenCore"]
        ),
    ]
)

// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Models",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "Models",
            targets: ["Models"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", from: "1.0.6"),
    ],
    targets: [
        .target(
            name: "Models",
            dependencies: [
                .product(name: "OrderedCollections", package: "swift-collections"),
            ],
            path: "Sources",
            resources: []
        )
    ]
)

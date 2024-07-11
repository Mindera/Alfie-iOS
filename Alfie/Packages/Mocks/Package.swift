// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Mocks",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "Mocks",
            targets: ["Mocks"]
        ),
    ],
    dependencies: [
        .package(path: "../Models")
    ],
    targets: [
        .target(
            name: "Mocks",
            dependencies: [
                .product(name: "Models", package: "Models"),
            ],
            path: "Sources"
        ),
    ]
)

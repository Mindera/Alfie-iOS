// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Common",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "Common",
            targets: ["Common"]),
        .library(name: "CommonTestUtils",
                 targets: ["CommonTestUtils"]),
    ],
    targets: [
        .target(name: "Common",
                path: "Sources"),
        .target(name: "CommonTestUtils",
                path: "TestUtils"),
    ]
)

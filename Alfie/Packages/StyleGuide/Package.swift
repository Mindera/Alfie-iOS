// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StyleGuide",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "StyleGuide",
            targets: ["StyleGuide"]),
    ],
    dependencies: [
        .package(path: "../Navigation"),
        .package(path: "../Common"),
        .package(path: "../Core"),
        .package(path: "../Models")
    ],
    targets: [
        .target(
            name: "StyleGuide",
            dependencies: [
                .product(name: "Navigation", package: "Navigation"),
                .product(name: "Common", package: "Common"),
                .product(name: "Core", package: "Core"),
                .product(name: "Models", package: "Models"),
            ],
            path: "Sources",
            resources: [
                .copy("Theme/Typography/Resources/SF-Pro-Display-Medium.otf"),
                .copy("Theme/Components/Loader/spin.gif"),
                .process("Theme/Typography/Resources/Fonts.xcassets"),
                .process("Theme/Color/Colors.xcassets"),
                .process("Theme/Images/ThemedImages.xcassets"),
                .process("Theme/Toggle/ToggleColor.xcassets")
            ]
        ),
        .testTarget(
              name: "StyleGuideTests",
              dependencies: [
                "StyleGuide",
                "Common",
                "Core"
              ]
        )
    ]
)

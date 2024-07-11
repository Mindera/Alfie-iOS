// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "Core",
            targets: ["Core"]),
    ],
    dependencies: [
        .package(path: "../Models"),
        .package(path: "../Mocks"),
        .package(path: "BFFGraphApi"),
        .package(path: "../Common"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", exact: "10.20.0"),
        .package(url: "https://github.com/kean/Nuke.git", exact: "12.4.0"),
        .package(url: "https://github.com/apollographql/apollo-ios.git", exact: "1.7.1"),
        .package(url: "https://github.com/onmyway133/EasyStash.git", exact: "1.1.9"),
        .package(url: "https://github.com/braze-inc/braze-swift-sdk", exact: "8.0.1"),
    ],
    targets: [
        .target(
            name: "Core",
            dependencies: [
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "NukeUI", package: "nuke"),
                .product(name: "Models", package: "Models"),
                .product(name: "Apollo", package: "apollo-ios"),
                .product(name: "Common", package: "Common"),
                .product(name: "BrazeKit", package: "braze-swift-sdk"),
                .product(name: "BFFGraphApi", package: "BFFGraphApi"),
                .product(name: "EasyStash", package: "EasyStash"),
            ],
            path: "Sources",
            resources: [
            ]
        ),
        .testTarget(
              name: "CoreTests",
              dependencies: [
                "Core",
                "Mocks",
                "Common",
                .product(name: "BFFGraphMocks", package: "BFFGraphApi"),
                .product(name: "Apollo", package: "apollo-ios"),
                .product(name: "CommonTestUtils", package: "Common"),
              ]
        )
    ]
)

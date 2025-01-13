// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AlfieKit",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Common",
            targets: ["Common"]
        ),
        .library(
            name: "Core",
            targets: ["Core"]
        ),
        .library(
            name: "Mocks",
            targets: ["Mocks"]
        ),
        .library(
            name: "Models",
            targets: ["Models"]
        ),
        .library(
            name: "Navigation",
            targets: ["Navigation"]
        ),
        .library(
            name: "StyleGuide",
            targets: ["StyleGuide"]
        ),
        
        .library(
            name: "CommonTestUtils",
            targets: ["CommonTestUtils"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(path: "AlfieKit/Core/BFFGraphApi"),
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            exact: "10.20.0"
        ),
        .package(
            url: "https://github.com/kean/Nuke.git",
            exact: "12.4.0"
        ),
        .package(
            url: "https://github.com/apollographql/apollo-ios.git",
            exact: "1.7.1"
        ),
        .package(
            url: "https://github.com/onmyway133/EasyStash.git",
            exact: "1.1.9"
        ),
        .package(
            url: "https://github.com/braze-inc/braze-swift-sdk",
            exact: "8.0.1"
        ),
        .package(
            url: "https://github.com/apple/swift-collections",
            from: "1.0.6"
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Common",
            path: "AlfieKit/Common/Sources"
        ),
        .target(
            name: "Core",
            dependencies: [
                "Models",
                "Common",
                "BFFGraphApi",
                "EasyStash",
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "NukeUI", package: "nuke"),
                .product(name: "Apollo", package: "apollo-ios"),
                .product(name: "BrazeKit", package: "braze-swift-sdk"),
            ],
            path: "AlfieKit/Core/Sources",
            resources: [
            ]
        ),
        .target(
            name: "Mocks",
            dependencies: [
                "Models"
            ],
            path: "AlfieKit/Mocks/Sources"
        ),
        .target(
            name: "Models",
            dependencies: [
                .product(
                    name: "OrderedCollections",
                    package: "swift-collections"
                ),
            ],
            path: "AlfieKit/Models/Sources",
            resources: []
        ),
        .target(
            name: "Navigation",
            path: "AlfieKit/Navigation/Sources"
        ),
        .target(
            name: "StyleGuide",
            dependencies: [
                "Navigation",
                "Common",
                "Core",
                "Models"
            ],
            path: "AlfieKit/StyleGuide/Sources",
            resources: [
                .copy("Theme/Typography/Resources/SF-Pro-Display-Medium.otf"),
                .copy("Theme/Components/Loader/spin.gif"),
                .process("Theme/Typography/Resources/Fonts.xcassets"),
                .process("Theme/Color/Colors.xcassets"),
                .process("Theme/Images/ThemedImages.xcassets"),
                .process("Theme/Toggle/ToggleColor.xcassets")
            ]
        ),
        
        
        .target(
            name: "CommonTestUtils",
            path: "AlfieKit/Common/TestUtils"
        ),
//        .testTarget(
//            name: "CoreTests",
//            dependencies: [
//                "Core",
//                "Mocks",
//                "Common",
//                .product(name: "BFFGraphMocks", package: "BFFGraphApi"),
//                .product(name: "Apollo", package: "apollo-ios"),
//                .product(name: "CommonTestUtils", package: "Common"),
//            ],
//            path: "AlfieKit/Core/Test"
//        ),
//        .testTarget(
//            name: "NavigationTests",
//            dependencies: [
//                "Navigation"
//            ],
//            path: "AlfieKit/Navigation/Test"
//        ),
//        .testTarget(
//            name: "StyleGuideTests",
//            dependencies: [
//                "StyleGuide",
//                "Common",
//                "Core"
//            ],
//            path: "AlfieKit/StyleGuide/Test"
//        )
    ]
)

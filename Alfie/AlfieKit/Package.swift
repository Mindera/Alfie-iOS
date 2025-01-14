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
            name: "BFFGraphApi",
            targets: ["BFFGraphApi"]
        ),
        .library(
            name: "BFFGraphMocks",
            targets: ["BFFGraphMocks"]
        ),
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
            name: "TestUtils",
            targets: ["TestUtils"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
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
            name: "BFFGraphApi",
            dependencies: [
                .product(name: "ApolloAPI", package: "apollo-ios"),
            ],
            path: "Sources/BFFGraph/Api"
        ),
        .target(
            name: "BFFGraphMocks",
            dependencies: [
                "BFFGraphApi",
                .product(name: "ApolloTestSupport", package: "apollo-ios"),
            ],
            path: "Sources/BFFGraph/Mocks"
        ),
        
        .target(
            name: "Common"
        ),
        
        .target(
            name: "Core",
            dependencies: [
                "Models",
                "Common",
                "BFFGraphApi",
                "EasyStash",
                .product(
                    name: "FirebaseRemoteConfig",
                    package: "firebase-ios-sdk"
                ),
                .product(
                    name: "FirebaseCrashlytics",
                    package: "firebase-ios-sdk"
                ),
                .product(
                    name: "FirebaseAnalytics",
                    package: "firebase-ios-sdk"
                ),
                .product(
                    name: "NukeUI",
                    package: "nuke"
                ),
                .product(
                    name: "Apollo",
                    package: "apollo-ios"
                ),
                .product(
                    name: "BrazeKit",
                    package: "braze-swift-sdk"
                ),
            ]
        ),
        
        .target(
            name: "Mocks",
            dependencies: [
                "Models"
            ]
        ),
        
        .target(
            name: "Models",
            dependencies: [
                .product(
                    name: "OrderedCollections",
                    package: "swift-collections"
                ),
            ]
        ),
        
        .target(
            name: "Navigation"
        ),
        
        .target(
            name: "StyleGuide",
            dependencies: [
                "Navigation",
                "Common",
                "Core",
                "Models"
            ],
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
            name: "TestUtils"
        ),
        
        .testTarget(
            name: "CoreTests",
            dependencies: [
                "Core",
                "Mocks",
                "Common",
                "TestUtils",
                "BFFGraphMocks",
                .product(
                    name: "Apollo",
                    package: "apollo-ios"
                ),
            ]
        ),
        .testTarget(
            name: "NavigationTests",
            dependencies: [
                "Navigation"
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

// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AlfieKit",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "BFFGraph",
            targets: ["BFFGraph"]
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
            name: "Model",
            targets: ["Model"]
        ),
        .library(
            name: "Navigation",
            targets: ["Navigation"]
        ),
        .library(
            name: "SharedUI",
            targets: ["SharedUI"]
        ),
        .library(
            name: "TestUtils",
            targets: ["TestUtils"]
        ),
        .library(
            name: "Utils",
            targets: ["Utils"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", exact: "1.1.4"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", exact: "1.18.3"),
        .package(url: "https://github.com/apollographql/apollo-ios.git", exact: "1.19.0"),
        .package(url: "https://github.com/braze-inc/braze-swift-sdk", exact: "11.9.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", exact: "11.11.0"),
        .package(url: "https://github.com/kean/Nuke.git", exact: "12.8.0"),
        .package(url: "https://github.com/Mindera/Alicerce.git", exact: "0.18.0"),
        .package(url: "https://github.com/Mindera/SwiftGenPlugin", exact: "6.6.4-mindera"),
        .package(url: "https://github.com/onmyway133/EasyStash.git", exact: "1.1.9"),
        .package(url: "https://github.com/pointfreeco/combine-schedulers", exact: "1.0.3"),
    ],
    targets: [
        .target(
            name: "BFFGraph",
            dependencies: [
                .product(name: "Apollo", package: "apollo-ios"),
                .product(name: "ApolloAPI", package: "apollo-ios"),
                .product(name: "ApolloTestSupport", package: "apollo-ios"),
            ]
        ),
        
        .target(
            name: "Core",
            dependencies: [
                "BFFGraph",
                "EasyStash",
                "Model",
                "Utils",
                .product(name: "AlicerceLogging", package: "Alicerce"),
                .product(name: "BrazeKit", package: "braze-swift-sdk"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseRemoteConfig",package: "firebase-ios-sdk"),
                .product(name: "NukeUI", package: "nuke"),
            ]
        ),
        
        .target(
            name: "Mocks",
            dependencies: [
                "Model",
                "Utils",
            ]
        ),
        
        .target(
            name: "Model",
            dependencies: [
                "Utils",
                .product(name: "AlicerceAnalytics", package: "Alicerce"),
                .product(name: "AlicerceLogging", package: "Alicerce"),
                .product(name: "OrderedCollections", package: "swift-collections"),
            ]
        ),
        
        .target(
            name: "Navigation"
        ),

        .target(
            name: "SharedUI",
            dependencies: [
                "Core",
                "Model",
                "Navigation",
                "Utils",
                .product(name: "AlicerceLogging", package: "Alicerce"),
            ],
            resources: [
                .copy("Theme/Typography/Resources/SF-Pro-Display-Medium.otf"),
                .copy("Theme/Components/Loader/spin.gif"),
                .process("Theme/Color/Colors.xcassets"),
                .process("Theme/Images/ThemedImages.xcassets"),
                .process("Theme/Toggle/ToggleColor.xcassets"),
                .process("Theme/Typography/Resources/Fonts.xcassets"),
                .process("Resources/Localization/L10n.xcstrings")
            ]
        ),
        
        .target(
            name: "TestUtils",
            dependencies: [
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),

        .target(
            name: "Utils"
        ),

        .testTarget(
            name: "BFFGraphTests",
            dependencies: [
                "BFFGraph",
                "Core",
                .product(name: "Apollo", package: "apollo-ios"),
            ]
        ),

        .testTarget(
            name: "CoreTests",
            dependencies: [
                "Core",
                "Mocks",
                "TestUtils",
                "Utils",
            ]
        ),

        .testTarget(
            name: "NavigationTests",
            dependencies: [
                "Navigation"
            ]
        ),

        .testTarget(
            name: "SharedUITests",
            dependencies: [
                "Core",
                "SharedUI",
                "Utils",
            ],
            swiftSettings: [
                .unsafeFlags(["-enable-bare-slash-regex"])
            ]
        ),
    ]
)

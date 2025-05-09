// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AlfieKit",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "BFFGraphAPI",
            targets: ["BFFGraphAPI"]
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
            name: "SharedUI",
            targets: ["SharedUI"]
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
            name: "BFFGraphAPI",
            dependencies: [
                .product(name: "Apollo", package: "apollo-ios"),
                .product(name: "ApolloAPI", package: "apollo-ios"),
            ],
            path: "Sources/BFFGraph/Api"
        ),
        .target(
            name: "BFFGraphMocks",
            dependencies: [
                "BFFGraphAPI",
                .product(name: "ApolloTestSupport", package: "apollo-ios"),
            ],
            path: "Sources/BFFGraph/Mocks"
        ),
        
        .target(
            name: "Common",
            dependencies: [
                .product(name: "AlicerceLogging", package: "Alicerce")
            ]
        ),
        
        .target(
            name: "Core",
            dependencies: [
                "BFFGraphAPI",
                "Common",
                "EasyStash",
                "Models",
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
                "Common",
                "Models"
            ]
        ),
        
        .target(
            name: "Models",
            dependencies: [
                .product(name: "AlicerceAnalytics", package: "Alicerce"),
                .product(name: "OrderedCollections", package: "swift-collections"),
            ]
        ),
        
        .target(
            name: "Navigation"
        ),

        .target(
            name: "SharedUI",
            resources: [
                .process("Resources/Localization/L10n.xcstrings")
            ]
        ),

        .target(
            name: "StyleGuide",
            dependencies: [
                "Common",
                "Core",
                "Models",
                "Navigation",
                .product(name: "AlicerceLogging", package: "Alicerce")
            ],
            resources: [
                .copy("Theme/Typography/Resources/SF-Pro-Display-Medium.otf"),
                .copy("Theme/Components/Loader/spin.gif"),
                .process("Theme/Color/Colors.xcassets"),
                .process("Theme/Images/ThemedImages.xcassets"),
                .process("Theme/Toggle/ToggleColor.xcassets"),
                .process("Theme/Typography/Resources/Fonts.xcassets")
            ]
        ),
        
        .target(
            name: "TestUtils",
            dependencies: [
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
        
        .testTarget(
            name: "CoreTests",
            dependencies: [
                "BFFGraphMocks",
                "Common",
                "Core",
                "Mocks",
                "TestUtils",
                .product(name: "Apollo", package: "apollo-ios"),
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
                "SharedUI"
            ],
            swiftSettings: [
                .unsafeFlags(["-enable-bare-slash-regex"])
            ]
        ),
        
        .testTarget(
            name: "StyleGuideTests",
            dependencies: [
                "Common",
                "Core",
                "StyleGuide"
            ]
        )
    ]
)

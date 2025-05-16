// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AlfieKit",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "AppFeature",
            targets: ["AppFeature"]
        ),
        .library(
            name: "Bag",
            targets: ["Bag"]
        ),
        .library(
            name: "BFFGraph",
            targets: ["BFFGraph"]
        ),
        .library(
            name: "CategorySelector",
            targets: ["CategorySelector"]
        ),
        .library(
            name: "Core",
            targets: ["Core"]
        ),
        .library(
            name: "DebugMenu",
            targets: ["DebugMenu"]
        ),
        .library(
            name: "DeepLink",
            targets: ["DeepLink"]
        ),
        .library(
            name: "Home",
            targets: ["Home"]
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
            name: "MyAccount",
            targets: ["MyAccount"]
        ),
        .library(
            name: "ProductDetails",
            targets: ["ProductDetails"]
        ),
        .library(
            name: "ProductListing",
            targets: ["ProductListing"]
        ),
        .library(
            name: "Search",
            targets: ["Search"]
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
        ),
        .library(
            name: "Web",
            targets: ["Web"]
        ),
        .library(
            name: "Wishlist",
            targets: ["Wishlist"]
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
            name: "AppFeature",
            dependencies: [
                "Bag",
                "CategorySelector",
                "Core",
                "Home",
                "Mocks",
                "Model",
                "Search",
                "SharedUI",
                "Utils",
                "Wishlist",
                .product(name: "OrderedCollections", package: "swift-collections"),
            ]
        ),

        .target(
            name: "Bag",
            dependencies: [
                "Model",
                "MyAccount",
                "ProductDetails",
                "SharedUI",
                "Wishlist",
            ]
        ),

        .target(
            name: "BFFGraph",
            dependencies: [
                .product(name: "Apollo", package: "apollo-ios"),
                .product(name: "ApolloAPI", package: "apollo-ios"),
                .product(name: "ApolloTestSupport", package: "apollo-ios"),
            ]
        ),

        .target(
            name: "CategorySelector",
            dependencies: [
                "Core",
                "Model",
                "MyAccount",
                "ProductDetails",
                "ProductListing",
                "Search",
                "SharedUI",
                "Utils",
                "Web",
                "Wishlist",
                .product(name: "OrderedCollections", package: "swift-collections"),
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
            name: "DebugMenu",
            dependencies: [
                "Core",
                "Mocks",
                "Model",
                "SharedUI",
            ]
        ),

        .target(
            name: "DeepLink",
            dependencies: [
                "Core",
                "Model",
            ],
            swiftSettings: [
                .unsafeFlags(["-enable-bare-slash-regex"])
            ]
        ),

        .target(
            name: "Home",
            dependencies: [
                "Core",
                "DebugMenu",
                "Model",
                "MyAccount",
                "ProductDetails",
                "ProductListing",
                "Search",
                "SharedUI",
                "Web",
                "Wishlist",
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
            name: "MyAccount",
            dependencies: [
                "Model",
                "SharedUI",
            ]
        ),

        .target(
            name: "ProductDetails",
            dependencies: [
                "Core",
                "Model",
                "SharedUI",
                "Web",
            ]
        ),

        .target(
            name: "ProductListing",
            dependencies: [
                "Core",
                "Model",
                "ProductDetails",
                "Search",
                "SharedUI",
            ]
        ),

        .target(
            name: "Search",
            dependencies: [
                "Model",
                "SharedUI",
                "Utils",
            ]
        ),

        .target(
            name: "SharedUI",
            dependencies: [
                "Core",
                "Mocks",
                "Model",
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

        .target(
            name: "Web",
            dependencies: [
                "Model",
                "SharedUI",
                "Utils",
            ]
        ),

        .target(
            name: "Wishlist",
            dependencies: [
                "Core",
                "Model",
                "MyAccount",
                "ProductDetails",
                "SharedUI",
                "Web",
            ]
        ),

        .testTarget(
            name: "AppFeatureTests",
            dependencies: [
                "AppFeature",
                "Core",
                "Mocks",
                "TestUtils",
            ]
        ),

        .testTarget(
            name: "BagTests",
            dependencies: [
                "Bag",
                "Mocks",
            ]
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
            name: "DeepLinkTests",
            dependencies: [
                "Core",
                "DeepLink",
                "Mocks",
                "Model",
                "TestUtils",
            ]
        ),

        .testTarget(
            name: "ProductDetailsTests",
            dependencies: [
                "ProductDetails",
                "Mocks",
                "TestUtils",
            ]
        ),

        .testTarget(
            name: "ProductListingTests",
            dependencies: [
                "ProductListing",
                "Mocks",
                "TestUtils",
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

        .testTarget(
            name: "WebTests",
            dependencies: [
                "Mocks",
                "TestUtils",
                "Web",
            ]
        ),
    ]
)

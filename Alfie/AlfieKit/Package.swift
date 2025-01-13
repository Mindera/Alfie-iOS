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
    ]
)

// MARK: - Common -

package.targets.append(
    contentsOf:
        [
            .target(
                name: "Common",
                path: "AlfieKit/Common/Sources"
            ),
            .target(
                name: "CommonTestUtils",
                path: "AlfieKit/Common/TestUtils"
            )
        ]
)

package.products.append(
    contentsOf:
        [
            .library(
                name: "Common",
                targets: ["Common"]
            ),
            .library(
                name: "CommonTestUtils",
                targets: ["CommonTestUtils"]
            )
        ]
)

// MARK: - Core -

package.targets.append(
    contentsOf:
        [
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
                ],
                path: "AlfieKit/Core/Sources"
            ),
            .testTarget(
                name: "CoreTests",
                dependencies: [
                    "Core",
                    "Mocks",
                    "Common",
                    "CommonTestUtils",
                    .product(
                        name: "BFFGraphMocks",
                        package: "BFFGraphApi"
                    ),
                    .product(
                        name: "Apollo",
                        package: "apollo-ios"
                    ),
                ],
                path: "AlfieKit/Core/Tests/CoreTests"
            )
        ]
)

package.products.append(
    contentsOf:
        [
            .library(
                name: "Core",
                targets: ["Core"]
            )
        ]
)

// MARK: - Mocks -

package.targets.append(
    contentsOf:
        [
            .target(
                name: "Mocks",
                dependencies: [
                    "Models"
                ],
                path: "AlfieKit/Mocks/Sources"
            )
        ]
)

package.products.append(
    contentsOf:
        [
            .library(
                name: "Mocks",
                targets: ["Mocks"]
            )
        ]
)

// MARK: - Models -

package.targets.append(
    contentsOf:
        [
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
            )
        ]
)

package.products.append(
    contentsOf:
        [
            .library(
                name: "Models",
                targets: ["Models"]
            )
        ]
)

// MARK: - Navigation -

package.targets.append(
    contentsOf:
        [
            .target(
                name: "Navigation",
                path: "AlfieKit/Navigation/Sources"
            ),
            .testTarget(
                name: "NavigationTests",
                dependencies: [
                    "Navigation"
                ],
                path: "AlfieKit/Navigation/Tests/NavigationTests"
            )
        ]
)

package.products.append(
    contentsOf:
        [
            .library(
                name: "Navigation",
                targets: ["Navigation"]
            )
        ]
)

// MARK: - StyleGuide -

package.targets.append(
    contentsOf:
        [
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
            .testTarget(
                name: "StyleGuideTests",
                dependencies: [
                    "StyleGuide",
                    "Common",
                    "Core"
                ],
                path: "AlfieKit/StyleGuide/Tests/StyleGuideTests"
            )
        ]
)

package.products.append(
    contentsOf:
        [
            .library(
                name: "StyleGuide",
                targets: ["StyleGuide"]
            )
        ]
)

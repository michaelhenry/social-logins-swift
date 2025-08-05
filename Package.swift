// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SocialLogins",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "SocialLoginsFeature",
            targets: ["SocialLoginsFeature"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMinor(from: "1.21.1")),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", .upToNextMinor(from: "9.0.0")),
        .package(url: "https://github.com/facebook/facebook-ios-sdk", .upToNextMinor(from: "18.0.0")),
    ],
    targets: [
        .target(
            name: "SocialLoginsFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "GoogleSignInSwift", package: "GoogleSignIn-iOS"),
                .product(name: "FacebookCore", package: "facebook-ios-sdk"),
                .product(name: "FacebookLogin", package: "facebook-ios-sdk"),
            ]
        ),
    ]
)

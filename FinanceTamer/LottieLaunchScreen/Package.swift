// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyApp",
    platforms: [
        .iOS(.v15) 
    ],
    products: [
        .library(
            name: "LottieLaunchScreen",
            targets: ["LottieLaunchScreen"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.4.0")
    ],
    targets: [
        .target(
            name: "LottieLaunchScreen",
            dependencies: [
                .product(name: "Lottie", package: "lottie-ios")
            ],
            resources: [.process("Assets")]
        ),
        .testTarget(
            name: "LottieLaunchScreenTests",
            dependencies: ["LottieLaunchScreen"]
        ),
    ]
)


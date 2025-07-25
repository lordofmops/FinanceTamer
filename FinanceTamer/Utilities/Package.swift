// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Utilities",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "PieChart", targets: ["PieChart"]),
    ],
    targets: [
        .target(
            name: "PieChart",
            path: "Sources/PieChart"
        ),
        .testTarget(
            name: "PieChartTests",
            dependencies: ["PieChart"],
            path: "Tests/PieChartTests"
        )
    ]
)

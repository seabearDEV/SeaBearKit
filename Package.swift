// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SeaBearKit",
    platforms: [
        .iOS(.v17), // iOS 17+ with optimal experience on iOS 18+
        .macOS(.v14)
    ],
    products: [
        // Library product for the reusable layouts
        .library(
            name: "SeaBearKit",
            targets: ["SeaBearKit"]
        ),
    ],
    targets: [
        // Main library target
        .target(
            name: "SeaBearKit",
            dependencies: []
        ),

        // Tests target
        .testTarget(
            name: "SeaBearKitTests",
            dependencies: ["SeaBearKit"]
        ),
    ]
)

// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IOSLayouts",
    platforms: [
        .iOS(.v18), // Liquid Glass materials available in iOS 18+
        .macOS(.v15)
    ],
    products: [
        // Library product for the reusable layouts
        .library(
            name: "IOSLayouts",
            targets: ["IOSLayouts"]
        ),
    ],
    targets: [
        // Main library target
        .target(
            name: "IOSLayouts",
            dependencies: []
        ),

        // Tests target
        .testTarget(
            name: "IOSLayoutsTests",
            dependencies: ["IOSLayouts"]
        ),
    ]
)

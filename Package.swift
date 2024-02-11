// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HandShadows",
    platforms: [.iOS(.v14), .macCatalyst(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HandShadows",
            targets: ["HandShadows"]
        )
    ],
    dependencies: [.package(url: "https://github.com/adamwulf/SwiftToolbox", branch: "fix/ios12"),
                   .package(url: "https://github.com/adamwulf/PerformanceBezier", branch: "main")],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HandShadows", dependencies: ["SwiftToolbox", "PerformanceBezier"]
        ),
        .testTarget(
            name: "HandShadowsTests",
            dependencies: ["HandShadows"]
        )
    ]
)

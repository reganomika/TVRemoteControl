// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TVRemoteControl",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TVRemoteControl",
            targets: ["TVRemoteControl"]),
    ],
    dependencies: [
        .package(url: "https://github.com/reganomika/TVDiscovery", branch: "main"),
        .package(url: "https://github.com/wdesimini/TVCommanderKit", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TVRemoteControl",
            dependencies: ["TVCommanderKit", "TVDiscovery"]
        ),
        .testTarget(
            name: "TVRemoteControlTests",
            dependencies: ["TVRemoteControl"]
        ),
    ]
)

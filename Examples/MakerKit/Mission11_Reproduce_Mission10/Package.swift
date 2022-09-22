// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Mission11_Reproduce_Mission10",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/madmachineio/SwiftIO.git", .branch("main")),
        .package(url: "https://github.com/madmachineio/MadBoards.git", .branch("main")),
        .package(url: "https://github.com/madmachineio/MadDrivers.git", .branch("main")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Mission11_Reproduce_Mission10",
            dependencies: [
                "SwiftIO",
                "MadBoards",
                .product(name: "SHT3x", package: "MadDrivers"),
                .product(name: "LCD1602", package: "MadDrivers")]),
        .testTarget(
            name: "Mission11_Reproduce_Mission10Tests",
            dependencies: ["Mission11_Reproduce_Mission10"]),
    ]
)

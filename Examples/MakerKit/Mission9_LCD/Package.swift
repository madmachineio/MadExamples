// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription
let package = Package(
    name: "Mission9_LCD",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/madmachineio/SwiftIO.git", branch: "develop"),
        .package(url: "https://github.com/madmachineio/MadBoards.git", branch: "develop"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "Mission9_LCD",
            dependencies: [
                "SwiftIO",
                "MadBoards"
            ]),
        .testTarget(
            name: "Mission9_LCDTests",
            dependencies: ["Mission9_LCD"]),
    ]
)

// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription
let package = Package(
    name: "LEDBlink",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/madmachineio/SwiftIO.git", branch: "feature/feather_v3"),
        .package(url: "https://github.com/madmachineio/MadBoards.git", branch: "feature/feather_v3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "LEDBlink",
            dependencies: [
                "SwiftIO",
                "MadBoards"
            ]),
        .testTarget(
            name: "LEDBlinkTests",
            dependencies: ["LEDBlink"]),
    ]
)
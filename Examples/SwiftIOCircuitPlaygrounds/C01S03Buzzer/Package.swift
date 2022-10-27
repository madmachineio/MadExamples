// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription
let package = Package(
    name: "C01S03Buzzer",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/madmachineio/SwiftIO.git", branch: "main"),
        .package(url: "https://github.com/madmachineio/MadBoards.git", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "C01S03Buzzer",
            dependencies: [
                "SwiftIO",
                "MadBoards"
            ]),
        .testTarget(
            name: "C01S03BuzzerTests",
            dependencies: ["C01S03Buzzer"]),
    ]
)

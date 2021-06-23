// swift-tools-version:5.3
import PackageDescription


let package = Package(
    name: "CoreImageExtensions",
    platforms: [.iOS(.v10), .macOS(.v10_15), .tvOS(.v10)],
    products: [
        .library(
            name: "CoreImageExtensions",
            type: .dynamic,
            targets: ["CoreImageExtensions"]),
    ],
    targets: [
        .target(
            name: "CoreImageExtensions",
            dependencies: [],
            path: "Sources"),
        .testTarget(
            name: "CoreImageExtensionsTests",
            dependencies: ["CoreImageExtensions"],
            path: "Tests",
            resources: [
              .process("Resources")
            ]),
    ]
)

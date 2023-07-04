// swift-tools-version:5.3
import PackageDescription


let package = Package(
    name: "CoreImageExtensions",
    platforms: [.iOS(.v13), .macOS(.v10_15), .tvOS(.v13)],
    products: [
        .library(
            name: "CoreImageExtensions",
            targets: ["CoreImageExtensions"]),
        .library(
            name: "CoreImageExtensions-dynamic",
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

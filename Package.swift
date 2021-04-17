// swift-tools-version:5.3
import PackageDescription


let package = Package(
    name: "CoreImageExtensions",
    platforms: [.iOS(.v9), .macOS(.v10_15), .tvOS(.v9)],
    products: [
        .library(
            name: "CoreImageExtensions",
            targets: ["CoreImageExtensions"]),
    ],
    targets: [
        .target(
            name: "CoreImageExtensions",
            dependencies: [],
            path: "Sources"),
    ]
)

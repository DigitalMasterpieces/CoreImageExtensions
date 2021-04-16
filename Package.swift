// swift-tools-version:5.3
import PackageDescription


let package = Package(
    name: "CoreImageExtensions",
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

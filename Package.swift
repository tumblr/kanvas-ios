// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Kanvas",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "Kanvas",
            targets: ["Kanvas"]),
    ],
    dependencies: [

    ],
    targets: [
        .target(
            name: "Kanvas",
            dependencies: [],
            path: "Classes")
    ]
)

// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Kanvas",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Kanvas",
            targets: ["Kanvas"]),
    ],
    dependencies: [
        .package(url: "https://github.com/TimOliver/TOCropViewController.git", branch: "main"),
        .package(url: "https://github.com/uber/ios-snapshot-test-case.git", from: "8.0.0"),
    ],
    targets: [
        .target(
            name: "Kanvas",
            dependencies: [.product(name: "CropViewController", package: "TOCropViewController")],
            path: "Classes",
            resources: [.process("Resources")]
        ),
        .target(
            name: "KanvasExample",
            dependencies: ["Kanvas"],
            path: "Example/KanvasExample",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "KanvasTests",
            dependencies: [
                "Kanvas",
                "KanvasExample",
                .product(name: "iOSSnapshotTestCase", package: "ios-snapshot-test-case")
            ],
            path: "Example/KanvasExampleTests"
        )
    ]
)

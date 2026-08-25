// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "GestureButton",
    platforms: [
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
        .macOS(.v13),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "GestureButton",
            targets: ["GestureButton"]
        )
    ],
    targets: [
        .target(
            name: "GestureButton"
        ),
        .testTarget(
            name: "GestureButtonTests",
            dependencies: ["GestureButton"]
        )
    ]
)

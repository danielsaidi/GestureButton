// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "GestureButton",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8),
        .macOS(.v12),
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

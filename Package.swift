// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CustomDragScrollBottomSheet",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "CustomDragScrollBottomSheet",
            targets: ["CustomDragScrollBottomSheet"]),
    ],
    targets: [
        .target(
            name: "CustomDragScrollBottomSheet"),
        .testTarget(
            name: "CustomDragScrollBottomSheetTests",
            dependencies: ["CustomDragScrollBottomSheet"]),
    ]
)

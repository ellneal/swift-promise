// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Promise",
    products: [
        .library(
            name: "Promise",
            targets: ["Promise"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ellneal/swift-result", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "Promise",
            dependencies: ["Result"]),
    ]
)

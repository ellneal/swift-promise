// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PromiseDevelopment",
    products: [],
    dependencies: [
        .package(url: "https://github.com/Realm/SwiftLint", from: "0.30.0"),
        .package(url: "https://github.com/Carthage/Carthage", .branch("master")),
    ],
    targets: [
        .target(name: "PromiseDevelopment",
                dependencies: []),
    ]
)

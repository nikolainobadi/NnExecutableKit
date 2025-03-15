// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NnExecutableKit",
    platforms: [
        .macOS(.v10_14),
    ], 
    products: [
        .library(
            name: "NnExecutableKit",
            targets: ["NnExecutableKit"]),
        .executable(
            name: "NnExecutableKitExecutable",
            targets: ["NnExecutableKitExecutable"]),
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
        .package(url: "https://github.com/kareman/SwiftShell", from: "5.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0")
    ],
    targets: [
        .target(
            name: "NnExecutableKit",
            dependencies: [
                "Files",
                "SwiftShell",
            ]
        ),
        .executableTarget(
            name: "NnExecutableKitExecutable",
            dependencies: [
                "NnExecutableKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(
            name: "NnExecutableKitTests",
            dependencies: [
                "NnExecutableKit"
            ]
        )
    ]
)

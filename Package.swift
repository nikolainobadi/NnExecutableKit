// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NnExecutableManager",
    platforms: [
        .macOS(.v10_14),
    ], 
    products: [
        .library(
            name: "NnExecutableManager",
            targets: ["NnExecutableManager"]),
        .executable(
            name: "NnExecutableManagerExecutable",
            targets: ["NnExecutableManagerExecutable"]),
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
        .package(url: "https://github.com/kareman/SwiftShell", from: "5.0.0"),
        .package(url: "https://github.com/nikolainobadi/SwiftPickerCLI", branch: "main"),
        .package(url: "https://github.com/nikolainobadi/NnConfigGen", branch: "main"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "0.3.0")
    ],
    targets: [
        .target(
            name: "NnExecutableManager",
            dependencies: [
                "Files",
                "SwiftShell",
                "SwiftPickerCLI",
                "NnConfigGen",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .executableTarget(
            name: "NnExecutableManagerExecutable",
            dependencies: ["NnExecutableManager"]
        )
    ]
)

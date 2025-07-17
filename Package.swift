// swift-tools-version: 5.9
//  EliteBiometric
//
//  Created by eliteself.tech on 15.07.2025.
//  Copyright © 2025 @eliteself.tech. All rights reserved.
//
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EliteBiometric",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "EliteBiometric",
            targets: ["EliteBiometric"]),
        .library(
            name: "EliteBiometricExtensions",
            targets: ["EliteBiometricExtensions"]),
        .library(
            name: "EliteBiometricExamples",
            targets: ["EliteBiometricExamples"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "EliteBiometric",
            dependencies: [],
            path: "Sources/EliteBiometric/Core",
            sources: [
                "EliteBiometric.swift",
                "KeychainManager.swift",
                "EliteSecure.swift",
                "CredentialsRepository.swift"
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release))
            ]
        ),
        .target(
            name: "EliteBiometricExtensions",
            dependencies: ["EliteBiometric"],
            path: "Sources/EliteBiometric/Extensions",
            sources: [
                "EliteBiometricCustomizable.swift",
                "KeychainPropertyWrapper.swift"
            ]
        ),
        .target(
            name: "EliteBiometricExamples",
            dependencies: ["EliteBiometric", "EliteBiometricExtensions"],
            path: "Sources/EliteBiometric/Examples",
            sources: [
                "EliteSecureExample.swift",
                "StorageExample.swift"
            ]
        ),
        .testTarget(
            name: "EliteBiometricTests",
            dependencies: ["EliteBiometric", "EliteBiometricExtensions"],
            path: "Tests/EliteBiometricTests"
        ),
    ]
)

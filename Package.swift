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
        // Main library - single import for everything
        .library(
            name: "EliteBiometric",
            targets: ["EliteBiometric"]),
    ],
    dependencies: [],
    targets: [
        // Single target with all core functionality
        .target(
            name: "EliteBiometric",
            dependencies: [],
            path: "Sources/EliteBiometric",
            sources: [
                "Core/EliteBiometric.swift",
                "Core/EliteKeychain.swift",
                "Core/CredentialsRepository.swift",
                "Core/EliteSecure.swift",
                "Core/UserDefault.swift"
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release))
            ]
        ),
        .testTarget(
            name: "EliteBiometricTests",
            dependencies: ["EliteBiometric"],
            path: "Tests/EliteBiometricTests"
        ),
    ]
)

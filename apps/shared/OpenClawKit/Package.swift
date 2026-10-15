// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "CapatiClawKit",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .watchOS(.v11),
    ],
    products: [
        .library(name: "CapatiClawProtocol", targets: ["CapatiClawProtocol"]),
        .library(name: "CapatiClawNativeState", targets: ["CapatiClawNativeState"]),
        .library(name: "CapatiClawKit", targets: ["CapatiClawKit"]),
        .library(name: "CapatiClawChatUI", targets: ["CapatiClawChatUI"]),
    ],
    traits: [
        .trait(name: "Talk", description: "ElevenLabs cloud TTS / talk support"),
        .default(enabledTraits: ["Talk"]),
    ],
    dependencies: [
        .package(url: "https://github.com/steipete/ElevenLabsKit", exact: "0.1.3"),
        .package(url: "https://github.com/groue/GRDB.swift.git", exact: "7.11.1"),
        .package(url: "https://github.com/mgriebling/SwiftMath", exact: "1.7.3"),
        .package(url: "https://github.com/swiftlang/swift-markdown", exact: "0.9.0"),
    ],
    targets: [
        .target(
            name: "CapatiClawProtocol",
            path: "Sources/CapatiClawProtocol",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ],
            plugins: ["GenerateGatewayProtocol"]),
        .plugin(
            name: "GenerateGatewayProtocol",
            capability: .buildTool()),
        .target(
            name: "CapatiClawNativeState",
            path: "Sources/CapatiClawNativeState",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .target(
            name: "CapatiClawKit",
            dependencies: [
                "CapatiClawNativeState",
                "CapatiClawProtocol",
                .product(
                    name: "ElevenLabsKit",
                    package: "ElevenLabsKit",
                    condition: .when(platforms: [.iOS, .macOS], traits: ["Talk"])),
            ],
            path: "Sources/CapatiClawKit",
            resources: [
                .process("Resources"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .target(
            name: "CapatiClawChatUI",
            dependencies: [
                "CapatiClawKit",
                "CapatiClawProtocol",
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "SwiftMath", package: "SwiftMath"),
            ],
            path: "Sources/CapatiClawChatUI",
            resources: [
                .copy("Resources/Mermaid"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .testTarget(
            name: "CapatiClawKitTests",
            dependencies: [
                "CapatiClawKit",
                "CapatiClawChatUI",
                "CapatiClawProtocol",
                .product(name: "GRDB", package: "GRDB.swift"),
            ],
            path: "Tests/CapatiClawKitTests",
            resources: [.copy("Fixtures")],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("SwiftTesting"),
            ]),
        .testTarget(
            name: "CapatiClawNativeStateTests",
            dependencies: ["CapatiClawNativeState"],
            path: "Tests/CapatiClawNativeStateTests",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("SwiftTesting"),
            ]),
    ])

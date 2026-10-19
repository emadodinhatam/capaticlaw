// swift-tools-version: 6.3
// Package manifest for the CapatiClaw macOS companion (menu bar app + IPC library).

import PackageDescription

let package = Package(
    name: "CapatiClaw",
    platforms: [
        .macOS("14.0"),
    ],
    products: [
        .library(name: "CapatiClawIPC", targets: ["CapatiClawIPC"]),
        .library(name: "CapatiClawDiscovery", targets: ["CapatiClawDiscovery"]),
        .executable(name: "CapatiClaw", targets: ["CapatiClaw"]),
        .executable(name: "capaticlaw-mac", targets: ["CapatiClawMacCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", exact: "3.1.0"),
        .package(url: "https://github.com/swiftlang/swift-subprocess.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.15.1"),
        .package(url: "https://github.com/sparkle-project/Sparkle", exact: "2.10.0"),
        .package(url: "https://github.com/capaticlaw/Peekaboo.git", exact: "4.9.2"),
        .package(url: "https://github.com/pointfreeco/swift-concurrency-extras", from: "1.4.1"),
        .package(path: "../shared/CapatiClawKit"),
        .package(path: "../shared/CapatiClawMLXTTSProtocol"),
        .package(path: "../swabble"),
    ],
    targets: [
        .target(
            name: "CapatiClawCameraPTZNative",
            path: "Sources/CapatiClawCameraPTZNative",
            publicHeadersPath: "include",
            linkerSettings: [
                .linkedFramework("CoreFoundation"),
                .linkedFramework("IOKit"),
            ]),
        .target(
            name: "CapatiClawIPC",
            dependencies: [],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .target(
            name: "CapatiClawDiscovery",
            dependencies: [
                .product(name: "CapatiClawKit", package: "CapatiClawKit"),
                .product(name: "Subprocess", package: "swift-subprocess"),
            ],
            path: "Sources/CapatiClawDiscovery",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .executableTarget(
            name: "CapatiClaw",
            dependencies: [
                "CapatiClawIPC",
                "CapatiClawDiscovery",
                "CapatiClawCameraPTZNative",
                .product(name: "CapatiClawNativeState", package: "CapatiClawKit"),
                .product(name: "CapatiClawKit", package: "CapatiClawKit"),
                .product(name: "CapatiClawChatUI", package: "CapatiClawKit"),
                .product(name: "CapatiClawMLXTTSProtocol", package: "CapatiClawMLXTTSProtocol"),
                .product(name: "CapatiClawProtocol", package: "CapatiClawKit"),
                .product(name: "SwabbleKit", package: "swabble"),
                .product(name: "Subprocess", package: "swift-subprocess"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Sparkle", package: "Sparkle"),
                .product(name: "PeekabooBridge", package: "Peekaboo"),
                .product(name: "PeekabooAutomationKit", package: "Peekaboo"),
                .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras"),
                .product(name: "KeyboardShortcuts", package: "KeyboardShortcuts"),
            ],
            exclude: [
                "Resources/Info.plist",
                "Resources/Localizable.xcstrings",
            ],
            resources: [
                .copy("Resources/CapatiClaw.icns"),
                .copy("Resources/NativeSessionCatalogs.json"),
                .copy("Resources/AppIcons"),
                .copy("Resources/DeviceModels"),
                .copy("Resources/ProviderIcons"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .executableTarget(
            name: "CapatiClawMacCLI",
            dependencies: [
                "CapatiClawIPC",
                "CapatiClawDiscovery",
                .product(name: "CapatiClawKit", package: "CapatiClawKit"),
                .product(name: "CapatiClawProtocol", package: "CapatiClawKit"),
            ],
            path: "Sources/CapatiClawMacCLI",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .target(
            name: "CapatiClawWebKitTestSupport",
            path: "Tests/CapatiClawWebKitTestSupport",
            publicHeadersPath: "include",
            linkerSettings: [
                .linkedFramework("WebKit"),
            ]),
        .testTarget(
            name: "CapatiClawIPCTests",
            dependencies: [
                "CapatiClawIPC",
                "CapatiClaw",
                "CapatiClawMacCLI",
                "CapatiClawDiscovery",
                "CapatiClawWebKitTestSupport",
                .product(name: "CapatiClawChatUI", package: "CapatiClawKit"),
                .product(name: "CapatiClawKit", package: "CapatiClawKit"),
                .product(name: "CapatiClawMLXTTSProtocol", package: "CapatiClawMLXTTSProtocol"),
                .product(name: "CapatiClawProtocol", package: "CapatiClawKit"),
                .product(name: "SwabbleKit", package: "swabble"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("SwiftTesting"),
            ]),
    ])

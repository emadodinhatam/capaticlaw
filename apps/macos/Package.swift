// swift-tools-version: 6.3
// Package manifest for the CapatiClaw macOS companion (menu bar app + IPC library).

import PackageDescription

let package = Package(
    name: "CapatiClaw",
    platforms: [
        .macOS("14.0"),
    ],
    products: [
        .library(name: "OpenClawIPC", targets: ["OpenClawIPC"]),
        .library(name: "OpenClawDiscovery", targets: ["OpenClawDiscovery"]),
        .executable(name: "CapatiClaw", targets: ["CapatiClaw"]),
        .executable(name: "capaticlaw-mac", targets: ["OpenClawMacCLI"]),
        .executable(name: "CapatiClawWrapper", targets: ["CapatiClawWrapper"]),
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", exact: "3.1.0"),
        .package(url: "https://github.com/swiftlang/swift-subprocess.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.15.1"),
        .package(url: "https://github.com/sparkle-project/Sparkle", exact: "2.10.0"),
        .package(url: "https://github.com/capaticlaw/Peekaboo.git", exact: "4.9.2"),
        .package(url: "https://github.com/pointfreeco/swift-concurrency-extras", from: "1.4.1"),
        .package(path: "../shared/OpenClawKit"),
        .package(path: "../shared/OpenClawMLXTTSProtocol"),
        .package(path: "../swabble"),
    ],
    targets: [
        .target(
            name: "OpenClawCameraPTZNative",
            path: "Sources/OpenClawCameraPTZNative",
            publicHeadersPath: "include",
            linkerSettings: [
                .linkedFramework("CoreFoundation"),
                .linkedFramework("IOKit"),
            ]),
        .target(
            name: "OpenClawIPC",
            dependencies: [],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .target(
            name: "OpenClawDiscovery",
            dependencies: [
                .product(name: "OpenClawKit", package: "OpenClawKit"),
                .product(name: "Subprocess", package: "swift-subprocess"),
            ],
            path: "Sources/OpenClawDiscovery",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .executableTarget(
            name: "CapatiClaw",
            dependencies: [
                "OpenClawIPC",
                "OpenClawDiscovery",
                "OpenClawCameraPTZNative",
                .product(name: "OpenClawNativeState", package: "OpenClawKit"),
                .product(name: "OpenClawKit", package: "OpenClawKit"),
                .product(name: "OpenClawChatUI", package: "OpenClawKit"),
                .product(name: "OpenClawMLXTTSProtocol", package: "OpenClawMLXTTSProtocol"),
                .product(name: "OpenClawProtocol", package: "OpenClawKit"),
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
            name: "CapatiClawWrapper",
            path: "Sources/CapatiClawWrapper",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .executableTarget(
            name: "OpenClawMacCLI",
            dependencies: [
                "OpenClawIPC",
                "OpenClawDiscovery",
                .product(name: "OpenClawKit", package: "OpenClawKit"),
                .product(name: "OpenClawProtocol", package: "OpenClawKit"),
            ],
            path: "Sources/OpenClawMacCLI",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .target(
            name: "OpenClawWebKitTestSupport",
            path: "Tests/OpenClawWebKitTestSupport",
            publicHeadersPath: "include",
            linkerSettings: [
                .linkedFramework("WebKit"),
            ]),
        .testTarget(
            name: "OpenClawIPCTests",
            dependencies: [
                "OpenClawIPC",
                "CapatiClaw",
                "OpenClawMacCLI",
                "OpenClawDiscovery",
                "OpenClawWebKitTestSupport",
                .product(name: "OpenClawChatUI", package: "OpenClawKit"),
                .product(name: "OpenClawKit", package: "OpenClawKit"),
                .product(name: "OpenClawMLXTTSProtocol", package: "OpenClawMLXTTSProtocol"),
                .product(name: "OpenClawProtocol", package: "OpenClawKit"),
                .product(name: "SwabbleKit", package: "swabble"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("SwiftTesting"),
            ]),
    ])

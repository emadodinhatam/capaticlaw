// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "CapatiClawMLXTTSProtocol",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(name: "CapatiClawMLXTTSProtocol", targets: ["CapatiClawMLXTTSProtocol"]),
    ],
    targets: [
        .target(name: "CapatiClawMLXTTSProtocol"),
        .testTarget(
            name: "CapatiClawMLXTTSProtocolTests",
            dependencies: ["CapatiClawMLXTTSProtocol"]),
    ])

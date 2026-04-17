// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MediasoupSwift",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "MediasoupSwift", targets: ["MediasoupSwift"]),
        .library(name: "WebRTC", targets: ["WebRTC"])
    ],
    targets: [
        .target(
            name: "MediasoupSwift",
            dependencies: [
                "Mediasoup",
                "WebRTC"
            ],
            path: "Empty"
        ),
        .binaryTarget(
            name: "Mediasoup",
            url: "https://github.com/riversidefm/ios-mediasoup/releases/download/0.0.1/Mediasoup.xcframework.zip",
            checksum: "287fdfa133fffaf4a65b82d95bdb3b7354e22fa1ceeaff8a38c8fd01c48b175c"
        ),
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/riversidefm/ios-mediasoup/releases/download/0.0.1/WebRTC.xcframework.zip",
            checksum: "81c98f9a208883352bca50d963901cf4c68ee2beeaf0ed9c0f801b7e2a4fce17"
        )
    ]
)

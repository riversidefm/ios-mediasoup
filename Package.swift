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
            url: "https://github.com/riversidefm/ios-mediasoup/releases/download/1.0.21/Mediasoup.xcframework.zip",
            checksum: "a1dbe69aaf95027b9e93cf436f03c4eeb5902c04aa6edbb0b72335fdba8c5685"
        ),
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/riversidefm/ios-mediasoup/releases/download/1.0.21/WebRTC.xcframework.zip",
            checksum: "d4d2b434dae5b43d3aea0bd02788ebdf88d6ea58532ca18b46ca2c8b4ba505cf"
        )
    ]
)

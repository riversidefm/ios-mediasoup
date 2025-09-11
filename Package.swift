// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MediasoupSwift",
    platforms: [
        .macOS(.v13),
        .iOS(.v15)
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
        .binaryTarget(name: "Mediasoup",
                      path: "bin/Mediasoup.xcframework"),
        .binaryTarget(name: "WebRTC",
                      path: "bin/WebRTC.xcframework")
    ]
)

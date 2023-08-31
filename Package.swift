// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "UvcKit",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "UvcKit",
            targets: ["UvcKit"]
        )
    ],
    targets: [
        .target(
            name: "UvcKit",
            cSettings: [
                .unsafeFlags(["-fno-objc-arc"]) // ADDING THE FLAG
            ]
        ),
        .executableTarget(
            name: "uvc-util",
            dependencies: [
                "UvcKit",
            ],
            cSettings: [
                .unsafeFlags(["-fno-objc-arc"]) // ADDING THE FLAG
            ]
        ),
    ]
)

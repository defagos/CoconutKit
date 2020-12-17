// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "CoconutKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "CoconutKit",
            targets: ["CoconutKit"]
        )
    ],
    targets: [
        .target(
            name: "CoconutKit",
            dependencies: ["HLSMAKVONotificationCenter"],
            resources: [
                .process("Resources")
            ],
            cSettings: [
                .define("NS_BLOCK_ASSERTIONS", to: "1", .when(configuration: .release))
            ]
        ),
        .target(
            name: "HLSMAKVONotificationCenter",
            cSettings: [
                .define("NS_BLOCK_ASSERTIONS", to: "1", .when(configuration: .release))
            ]
        )
    ]
)

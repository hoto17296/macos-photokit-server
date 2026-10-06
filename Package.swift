// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "photokit-server",
    platforms: [.macOS("27.0")],
    products: [
        .executable(name: "photokit-server", targets: ["photokit-server"])
    ],
    dependencies: [
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.27.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.8.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.0"),
    ],
    targets: [
        .target(
            name: "PhotoKitServer",
            dependencies: [
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "Logging", package: "swift-log"),
            ],
            resources: [
                // Compiled into the binary, so it works wherever the executable is copied.
                .embedInCode("openapi.json")
            ]
        ),
        .executableTarget(
            name: "photokit-server",
            dependencies: [
                "PhotoKitServer",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log"),
            ],
            linkerSettings: [
                // Embed Info.plist (NSPhotoLibraryUsageDescription) into the binary.
                // Without it, accessing the photo library crashes the process.
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Support/Info.plist",
                ])
            ]
        ),
        .testTarget(
            name: "PhotoKitServerTests",
            dependencies: [
                "PhotoKitServer",
                .product(name: "HummingbirdTesting", package: "hummingbird"),
            ]
        ),
    ]
)

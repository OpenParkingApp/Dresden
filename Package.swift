// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Dresden",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v11),
        .watchOS(.v4),
        .tvOS(.v11),
    ],
    products: [
        .library(
            name: "Dresden",
            targets: ["Dresden"]),
    ],
    dependencies: [
        .package(url: "https://github.com/OpenParkingApp/OpenParking", .upToNextMinor(from: "0.11.0")),
        .package(url: "https://github.com/scinfu/SwiftSoup", from: "2.3.0"),
    ],
    targets: [
        .target(
            name: "Dresden",
            dependencies: ["OpenParking", "SwiftSoup"],
            resources: [
                .process("geojson.json"),
            ]),
        .testTarget(
            name: "DresdenTests",
            dependencies: [
                "Dresden",
                .product(name: "OpenParkingTestSupport", package: "OpenParking"),
            ]),
    ]
)

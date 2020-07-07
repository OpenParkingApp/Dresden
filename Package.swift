// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Dresden",
    products: [
        .library(
            name: "Dresden",
            targets: ["Dresden"]),
    ],
    dependencies: [
        .package(url: "https://github.com/OpenParkingApp/OpenParking", .upToNextMinor(from: "0.10.0")),
        .package(url: "https://github.com/scinfu/SwiftSoup", from: "2.2.0"),
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

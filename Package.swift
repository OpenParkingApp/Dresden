// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "OpenParkingDresden",
    products: [
        .library(
            name: "OpenParkingDresden",
            targets: ["OpenParkingDresden"]),
    ],
    dependencies: [
        .package(url: "https://github.com/OpenParkingApp/OpenParkingBase.git", .upToNextMinor(from: "0.3.0")),
        .package(url: "https://github.com/scinfu/SwiftSoup", from: "2.2.0"),
    ],
    targets: [
        .target(
            name: "OpenParkingDresden",
            dependencies: ["OpenParkingBase", "SwiftSoup"]),
        .testTarget(
            name: "OpenParkingDresdenTests",
            dependencies: [
                "OpenParkingDresden",
                .product(name: "OpenParkingTests", package: "OpenParkingBase"),
            ]),
    ]
)

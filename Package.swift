// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "OpenParkingDresden",
    products: [
        .library(
            name: "OpenParkingDresden",
            targets: ["OpenParkingDresden"]),
    ],
    dependencies: [
        .package(path: "../OpenParkingBase"),
        .package(url: "https://github.com/scinfu/SwiftSoup", from: "2.2.0"),
    ],
    targets: [
        .target(
            name: "OpenParkingDresden",
            dependencies: ["OpenParkingBase", "SwiftSoup"]),
        .testTarget(
            name: "OpenParkingDresdenTests",
            dependencies: ["OpenParkingTests", "OpenParkingDresden"]),
    ]
)

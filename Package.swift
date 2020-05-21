// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Dresden",
    products: [
        .library(
            name: "Dresden",
            targets: ["Dresden"]),
    ],
    dependencies: [
        .package(url: "https://github.com/OpenParkingApp/Datasource.git", .upToNextMinor(from: "0.8.0")),
        .package(url: "https://github.com/scinfu/SwiftSoup", from: "2.2.0"),
    ],
    targets: [
        .target(
            name: "Dresden",
            dependencies: ["Datasource", "SwiftSoup"]),
        .testTarget(
            name: "DresdenTests",
            dependencies: [
                "Dresden",
                .product(name: "DatasourceValidation", package: "Datasource"),
            ]),
    ]
)

// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "ZipHeaderToAsn1",
  products: [
    .library(
      name: "ZipHeaderToAsn1",
      targets: ["ZipHeaderToAsn1"])
  ],
  dependencies: [
    .package(url: "https://github.com/realm/SwiftLint", from: "0.59.1"),
    .package(url: "https://github.com/apple/swift-asn1", from: "1.4.0"),
    .package(
      url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.5",
    ),
  ],
  targets: [
    .target(
      name: "ZipHeaderToAsn1",
      dependencies: [
        .product(name: "SwiftASN1", package: "swift-asn1")
      ],
    ),
    .testTarget(
      name: "ZipHeaderToAsn1Tests",
      dependencies: ["ZipHeaderToAsn1"]
    ),
  ]
)

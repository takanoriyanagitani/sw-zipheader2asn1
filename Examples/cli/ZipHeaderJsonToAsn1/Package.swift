// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "ZipHeaderJsonToAsn1",
  platforms: [
    .macOS(.v15)
  ],
  dependencies: [
    .package(url: "https://github.com/realm/SwiftLint", from: "0.59.1"),
    .package(path: "../../.."),
  ],
  targets: [
    .executableTarget(
      name: "ZipHeaderJsonToAsn1",
      dependencies: [
        .product(name: "ZipHeaderToAsn1", package: "sw-zipheader2asn1")
      ],
    )
  ]
)

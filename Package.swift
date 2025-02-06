// swift-tools-version:6.0

import PackageDescription

let package = Package(
  name: "MoreCollections",
  products: [
    .library(
      name: "MoreCollections",
      targets: ["MoreCollections"]),
    ],
    targets: [
      .target(name: "MoreCollections"),
      .testTarget(
        name: "MoreCollectionsTests",
        dependencies: ["MoreCollections"]),
    ])

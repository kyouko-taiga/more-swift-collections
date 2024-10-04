// swift-tools-version: 5.9

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

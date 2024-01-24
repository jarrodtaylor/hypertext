// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "HyperText",
  platforms: [.macOS(.v13)],
    dependencies: [
      .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
      .package(url: "https://github.com/johnsundell/ink.git", from: "0.1.0"),
    ],
    targets: [
      .executableTarget(
        name: "hypertext",
        dependencies: [
          .product(name: "ArgumentParser", package: "swift-argument-parser"),
          .product(name: "Ink", package: "ink"),
        ]
      ),
    ]
  )

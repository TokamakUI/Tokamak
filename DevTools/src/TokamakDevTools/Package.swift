// swift-tools-version:5.3
import PackageDescription
let package = Package(
  name: "TokamakDevTools",
  platforms: [.macOS(.v10_15)],
  products: [
    .executable(name: "TokamakDevTools", targets: ["TokamakDevTools"]),
  ],
  dependencies: [
    .package(name: "Tokamak", path: "../../../"),
    .package(url: "https://github.com/fabianfett/pure-swift-json.git", from: "0.4.0"),
  ],
  targets: [
    .target(
      name: "TokamakDevTools",
      dependencies: [
        .product(name: "TokamakDOM", package: "Tokamak"),
        .product(name: "PureSwiftJSON", package: "pure-swift-json"),
      ]
    ),
    .testTarget(
      name: "TokamakDevToolsTests",
      dependencies: ["TokamakDevTools"]
    ),
  ]
)

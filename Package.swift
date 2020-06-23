// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to
// build this package.

import PackageDescription

let package = Package(
  name: "Tokamak",
  platforms: [
    .macOS(.v10_15),
  ],
  products: [
    // Products define the executables and libraries produced by a package,
    // and make them visible to other packages.
    .executable(
      name: "TokamakDemo",
      targets: ["TokamakDemo"]
    ),
    .library(
      name: "TokamakDOM",
      targets: ["TokamakDOM"]
    ),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    .package(url: "https://github.com/kateinoigakukun/JavaScriptKit.git", .revision("47f2bb1")),
    .package(url: "https://github.com/MaxDesiatov/Runtime.git", .branch("wasi-build")),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define
    // a module or a test suite.
    // Targets can depend on other targets in this package, and on products
    // in packages which this package depends on.
    .target(
      name: "TokamakCore",
      dependencies: ["Runtime"]
    ),
    .target(
      name: "TokamakDemo",
      dependencies: ["JavaScriptKit", "TokamakCore", "TokamakDOM"]
    ),
    .target(
      name: "TokamakDOM",
      dependencies: ["JavaScriptKit", "TokamakCore"]
    ),
    .target(
      name: "TokamakTestRenderer",
      dependencies: ["TokamakCore"]
    ),
    .testTarget(
      name: "TokamakTests",
      dependencies: ["TokamakDemo", "TokamakTestRenderer"]
    ),
  ]
)

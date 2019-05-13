// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to
// build this package.

import PackageDescription

let package = Package(
  name: "Tokamak",
  products: [
    // Products define the executables and libraries produced by a package,
    // and make them visible to other packages.
    .library(
      name: "Tokamak",
      targets: ["Tokamak"]
    ),
    .library(
      name: "TokamakUIKit",
      targets: ["TokamakUIKit"]
    ),
    .library(
      name: "TokamakAppKit",
      targets: ["TokamakAppKit"]
    ),
    .library(
      name: "TokamakTestRenderer",
      targets: ["TokamakTestRenderer"]
    ),
    .library(
      name: "TokamakLint",
      targets: ["TokamakLint"]
    ),
    .executable(name: "tokamak", targets: ["TokamakCLI"]),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-syntax.git", .exact("0.50000.0")),
    .package(url: "https://github.com/jakeheis/SwiftCLI", from: "5.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define
    // a module or a test suite.
    // Targets can depend on other targets in this package, and on products
    // in packages which this package depends on.
    .target(
      name: "Tokamak",
      dependencies: []
    ),
    .target(
      name: "TokamakDemo",
      dependencies: ["Tokamak"]
    ),
    .target(
      name: "TokamakUIKit",
      dependencies: ["Tokamak"]
    ),
    .target(
      name: "TokamakAppKit",
      dependencies: ["Tokamak"]
    ),
    .target(
      name: "TokamakTestRenderer",
      dependencies: ["Tokamak"]
    ),
    .target(
      name: "TokamakCLI",
      dependencies: ["TokamakLint", "SwiftCLI"]
    ),
    .target(
      name: "TokamakLint",
      dependencies: ["SwiftSyntax"]
    ),
    .testTarget(
      name: "TokamakTests",
      dependencies: ["TokamakTestRenderer"]
    ),
    .testTarget(
      name: "TokamakCLITests",
      dependencies: ["TokamakLint"]
    ),
  ]
)

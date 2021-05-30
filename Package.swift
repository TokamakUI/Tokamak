// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to
// build this package.

import PackageDescription

let package = Package(
  name: "Tokamak",
  platforms: [
    .macOS(.v11),
    .iOS(.v13),
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
    .library(
      name: "TokamakStaticHTML",
      targets: ["TokamakStaticHTML"]
    ),
    .executable(
      name: "TokamakStaticDemo",
      targets: ["TokamakStaticDemo"]
    ),
    .library(
      name: "TokamakGTK",
      targets: ["TokamakGTK"]
    ),
    .executable(
      name: "TokamakGTKDemo",
      targets: ["TokamakGTKDemo"]
    ),
    .library(
      name: "TokamakShim",
      targets: ["TokamakShim"]
    ),
    .executable(
      name: "TokamakStaticHTMLBenchmark",
      targets: ["TokamakStaticHTMLBenchmark"]
    ),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    .package(
      url: "https://github.com/swiftwasm/JavaScriptKit.git",
      .upToNextMinor(from: "0.10.0")
    ),
    .package(url: "https://github.com/OpenCombine/OpenCombine.git", from: "0.12.0"),
    .package(url: "https://github.com/swiftwasm/OpenCombineJS.git", .upToNextMinor(from: "0.1.1")),
    .package(name: "Benchmark", url: "https://github.com/google/swift-benchmark", from: "0.1.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define
    // a module or a test suite.
    // Targets can depend on other targets in this package, and on products
    // in packages which this package depends on.
    .target(
      name: "CombineShim",
      dependencies: [.product(
        name: "OpenCombine",
        package: "OpenCombine",
        condition: .when(platforms: [.wasi, .linux])
      )]
    ),
    .target(
      name: "TokamakCore",
      dependencies: ["CombineShim"]
    ),
    .target(
      name: "TokamakShim",
      dependencies: [
        .target(name: "TokamakDOM", condition: .when(platforms: [.wasi])),
        .target(name: "TokamakGTK", condition: .when(platforms: [.linux])),
      ]
    ),
    .systemLibrary(
      name: "CGTK",
      pkgConfig: "gtk+-3.0",
      providers: [
        .apt(["libgtk+-3.0", "gtk+-3.0"]),
        // .yum(["gtk3-devel"]),
        .brew(["gtk+3"]),
      ]
    ),
    .systemLibrary(
      name: "CGDK",
      pkgConfig: "gdk-3.0",
      providers: [
        .apt(["libgtk+-3.0", "gtk+-3.0"]),
        // .yum(["gtk3-devel"]),
        .brew(["gtk+3"]),
      ]
    ),
    .target(
      name: "TokamakGTKCHelpers",
      dependencies: ["CGTK"]
    ),
    .target(
      name: "TokamakGTK",
      dependencies: ["TokamakCore", "CGTK", "CGDK", "TokamakGTKCHelpers", "CombineShim"]
    ),
    .target(
      name: "TokamakGTKDemo",
      dependencies: ["TokamakGTK"],
      resources: [.copy("logo-header.png")]
    ),
    .target(
      name: "TokamakStaticHTML",
      dependencies: [
        "TokamakCore",
      ]
    ),
    .target(
      name: "TokamakCoreBenchmark",
      dependencies: [
        "Benchmark",
        "TokamakCore",
      ]
    ),
    .target(
      name: "TokamakStaticHTMLBenchmark",
      dependencies: [
        "Benchmark",
        "TokamakStaticHTML",
      ]
    ),
    .target(
      name: "TokamakDOM",
      dependencies: [
        "CombineShim",
        "OpenCombineJS",
        "TokamakCore",
        "TokamakStaticHTML",
        .product(
          name: "JavaScriptKit",
          package: "JavaScriptKit",
          condition: .when(platforms: [.wasi])
        ),
      ]
    ),
    .target(
      name: "TokamakDemo",
      dependencies: [
        "TokamakShim",
        .product(
          name: "JavaScriptKit",
          package: "JavaScriptKit",
          condition: .when(platforms: [.wasi])
        ),
      ],
      resources: [.copy("logo-header.png")]
    ),
    .target(
      name: "TokamakStaticDemo",
      dependencies: [
        "TokamakStaticHTML",
      ]
    ),
    .target(
      name: "TokamakTestRenderer",
      dependencies: ["TokamakCore"]
    ),
    .testTarget(
      name: "TokamakTests",
      dependencies: ["TokamakTestRenderer"]
    ),
    .testTarget(
      name: "TokamakStaticHTMLTests",
      dependencies: ["TokamakStaticHTML"]
    ),
  ]
)

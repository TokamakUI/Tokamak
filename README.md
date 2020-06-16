# Tokamak

## SwiftUI-compatible framework for building browser apps with WebAssembly

[![Build Status](https://dev.azure.com/max0484/max/_apis/build/status/MaxDesiatov.Tokamak?branchName=main)](https://dev.azure.com/max0484/max/_build/latest?definitionId=3&branchName=main)
[![Coverage](https://img.shields.io/codecov/c/github/MaxDesiatov/Tokamak/main.svg?style=flat)](https://codecov.io/gh/maxdesiatov/Tokamak)

The WebAssembly/DOM renderer built for [SwiftWasm](https://swiftwasm.org)
is not ready yet. The reconciler and the test renderer already expose a
SwiftUI API, but the actual DOM renderer is currently blocked by [a few SwiftWasm
issues](https://github.com/swiftwasm/swift/issues/597).

## Acknowledgments

- Thanks to the [Swift community](https://swift.org/community/) for
  building one of the best programming languages available!
- Thanks to [SwiftWebUI](https://github.com/SwiftWebUI/SwiftWebUI),
  [Render](https://github.com/alexdrone/Render),
  [ReSwift](https://github.com/ReSwift/ReSwift), [Katana
  UI](https://github.com/BendingSpoons/katana-ui-swift) and
  [Komponents](https://github.com/freshOS/Komponents) for inspiration!

## Contributing

This project adheres to the [Contributor Covenant Code of
Conduct](https://github.com/MaxDesiatov/Tokamak/blob/main/CODE_OF_CONDUCT.md).
By participating, you are expected to uphold this code. Please report
unacceptable behavior to conduct@tokamak.dev.

## Maintainers

[Max Desiatov](https://desiatov.com)

## License

Tokamak is available under the Apache 2.0 license. See the
[LICENSE](https://github.com/MaxDesiatov/Tokamak/blob/main/LICENSE) file for
more info.

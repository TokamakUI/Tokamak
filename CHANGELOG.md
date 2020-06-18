# 0.2.0 (18 June, 2020)

This is the first release that supports WebAssembly and browsers
with the new `TokamakDOM` module. The API now closely follows SwiftUI,
while the new React-like API is no longer available. Unfortunately,
since older versions of iOS don't support [opaque
types](https://docs.swift.org/swift-book/LanguageGuide/OpaqueTypes.html),
and you already can use SwiftUI on iOS versions that do support it, iOS and macOS
renderers are no longer available.

# 0.1.2 (18 March, 2019)

Update example code in README for CocoaPods page.

# 0.1.1 (18 March, 2019)

Update rendered README.md on CocoaPods page.

# 0.1.0 (18 March, 2019)

First release with an iOS renderer for UIKit and a basic macOS renderer for
AppKit.

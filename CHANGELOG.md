# 0.2.0 (21 July, 2020)

This is the first release that supports WebAssembly and browser apps with the new `TokamakDOM`
module. The API now closely follows SwiftUI, while the new React-like API is no longer available.
Unfortunately, since older versions of iOS don't support [opaque
types](https://docs.swift.org/swift-book/LanguageGuide/OpaqueTypes.html), and you already can use
SwiftUI on iOS versions that do support it, iOS and macOS renderers are no longer available. Many
thanks to [@carson-katri](https://github.com/carson-katri), [@j-f1](https://github.com/j-f1),
[@helje5](https://github.com/helje5), [@hodovani](https://github.com/hodovani),
[@Outcue](https://github.com/Outcue), [@filip-sakel](https://github.com/filip-sakel) and
[@noontideox](https://github.com/noontideox) for their contributions to this release!

**Closed issues:**

- State vars have to be first ([#190](https://github.com/swiftwasm/Tokamak/issues/190))
- Implicit 8 pixel margin added to html body
  ([#188](https://github.com/swiftwasm/Tokamak/issues/188))
- Unable to set Color value ([#186](https://github.com/swiftwasm/Tokamak/issues/186))
- Crash in protocol conformance code ([#167](https://github.com/swiftwasm/Tokamak/issues/167))
- Extend Path to match the SwiftUI API ([#156](https://github.com/swiftwasm/Tokamak/issues/156))
- Some primitive Views cannot access @Environment
  ([#139](https://github.com/swiftwasm/Tokamak/issues/139))
- Logo for the project ([#132](https://github.com/swiftwasm/Tokamak/issues/132))
- ZStack? ([#111](https://github.com/swiftwasm/Tokamak/issues/111))
- View has - by default - a Body of type Never.
  ([#110](https://github.com/swiftwasm/Tokamak/issues/110))
- Getting value of type 'String' has no member 'components'
  ([#108](https://github.com/swiftwasm/Tokamak/issues/108))
- Does iOS 10 work? ([#105](https://github.com/swiftwasm/Tokamak/issues/105))
- Add Tokamak project linter ([#77](https://github.com/swiftwasm/Tokamak/issues/77))
- Ambiguous reference to member 'node' ([#68](https://github.com/swiftwasm/Tokamak/issues/68))

**Merged pull requests:**

- Move view files to separate subdirectories ([#194](https://github.com/swiftwasm/Tokamak/pull/194))
  via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Add `UIColor` stub and new `Color.init(_:UIColor)`
  ([#196](https://github.com/swiftwasm/Tokamak/pull/196)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Add Toggle implementation ([#159](https://github.com/swiftwasm/Tokamak/pull/159)) via
  [@j-f1](https://github.com/j-f1)
- Add `TokamakShim` module to simplify imports
  ([#192](https://github.com/swiftwasm/Tokamak/pull/192)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Organize all the re-exports into a single file
  ([#193](https://github.com/swiftwasm/Tokamak/pull/193)) via [@j-f1](https://github.com/j-f1)
- Add `Picker` and `PopUpButtonPickerStyle` as default
  ([#149](https://github.com/swiftwasm/Tokamak/pull/149)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Add @EnvironmentObject ([#170](https://github.com/swiftwasm/Tokamak/pull/170)) via
  [@carson-katri](https://github.com/carson-katri)
- Allow non-consecutive state variables ([#191](https://github.com/swiftwasm/Tokamak/pull/191)) via
  [@j-f1](https://github.com/j-f1)
- Add @ObservedObject implementation ([#171](https://github.com/swiftwasm/Tokamak/pull/171)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Avoid AnyView in the Counter code ([#168](https://github.com/swiftwasm/Tokamak/pull/168)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Mention `#webassembly` SwiftPM Slack channel in README.md
  ([#187](https://github.com/swiftwasm/Tokamak/pull/187)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Add LazyHGrid and LazyVGrid ([#179](https://github.com/swiftwasm/Tokamak/pull/179)) via
  [@carson-katri](https://github.com/carson-katri)
- Implement `static func Binding<Value>.constant`
  ([#178](https://github.com/swiftwasm/Tokamak/pull/178)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Extend Color to match SwiftUI ([#177](https://github.com/swiftwasm/Tokamak/pull/177)) via
  [@carson-katri](https://github.com/carson-katri)
- Add Text concatenation via + operator ([#174](https://github.com/swiftwasm/Tokamak/pull/174)) via
  [@carson-katri](https://github.com/carson-katri)
- Extend Path to match SwiftUI ([#172](https://github.com/swiftwasm/Tokamak/pull/172)) via
  [@carson-katri](https://github.com/carson-katri)
- Allow modified views to fill their parent if a child requires it
  ([#165](https://github.com/swiftwasm/Tokamak/pull/165)) via
  [@carson-katri](https://github.com/carson-katri)
- Build macOS demo on CI ([#164](https://github.com/swiftwasm/Tokamak/pull/164)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Add List and related Views ([#147](https://github.com/swiftwasm/Tokamak/pull/147)) via
  [@carson-katri](https://github.com/carson-katri)
- ViewBuilder buildIf fix ([#162](https://github.com/swiftwasm/Tokamak/pull/162)) via
  [@carson-katri](https://github.com/carson-katri)
- Use `let` instead of `var` in `TextFieldStyleKey: EnvironmentKey`
  ([#160](https://github.com/swiftwasm/Tokamak/pull/160)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Update Acknowledgments section in README.md
  ([#157](https://github.com/swiftwasm/Tokamak/pull/157)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Credit SwiftWebUI in a special way in README.md
  ([#140](https://github.com/swiftwasm/Tokamak/pull/140)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Add Group implementation ([#150](https://github.com/swiftwasm/Tokamak/pull/150)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Update AnyView status in progress.md ([#151](https://github.com/swiftwasm/Tokamak/pull/151)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Use a range instead of an array in ForEach ([#153](https://github.com/swiftwasm/Tokamak/pull/153))
  via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Documentation comments ([#143](https://github.com/swiftwasm/Tokamak/pull/143)) via
  [@carson-katri](https://github.com/carson-katri)
- Add Xcode project and native targets ([#142](https://github.com/swiftwasm/Tokamak/pull/142)) via
  [@j-f1](https://github.com/j-f1)
- Add AppearanceActionModifier, onAppear/onDisappear
  ([#145](https://github.com/swiftwasm/Tokamak/pull/145)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Add doc comment to the ViewDeferredToRenderer protocol
  ([#144](https://github.com/swiftwasm/Tokamak/pull/144)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)

# 0.1.2 (18 March, 2019)

Update example code in README for CocoaPods page.

# 0.1.1 (18 March, 2019)

Update rendered README.md on CocoaPods page.

# 0.1.0 (18 March, 2019)

First release with an iOS renderer for UIKit and a basic macOS renderer for
AppKit.

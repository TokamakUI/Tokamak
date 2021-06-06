# 0.7.0 (3 May 2021)

This release introduces new view types such as `DatePicker`, new modifiers such as `shadow`,
improves test coverage, updates dependencies, and fixes multiple bugs and crashes. Additionally,
a proof of concept GTK renderer is now available in the `TokamakGTK` module.

Many thanks to (in alphabetical order)
[@carson-katri](https://github.com/carson-katri), [@filip-sakel](https://github.com/filip-sakel),
[@foscomputerservices](https://github.com/foscomputerservices), [@literalpie](https://github.com/literalpie),
[@mattpolzin](https://github.com/mattpolzin), [@mortenbekditlevsen](https://github.com/mortenbekditlevsen),
and [@Snowy1803](https://github.com/Snowy1803) for their contributions to this release!

**Closed issues:**

- `@ObservedObject` is a get-only property ([#392](https://github.com/TokamakUI/Tokamak/issues/392))
- What is the difference between `HTML` and `DynamicHTML`? ([#388](https://github.com/TokamakUI/Tokamak/issues/388))
- Reduce `View.body` Visibility ([#385](https://github.com/TokamakUI/Tokamak/issues/385))
- Verify that type constructor names contain contain module names ([#368](https://github.com/TokamakUI/Tokamak/issues/368))
- Crash when using a `View` with optional content ([#362](https://github.com/TokamakUI/Tokamak/issues/362))
- Set up code coverage reports on GitHub Actions ([#350](https://github.com/TokamakUI/Tokamak/issues/350))
- Shadow support ([#324](https://github.com/TokamakUI/Tokamak/issues/324))
- Implement `DatePicker` view in the DOM renderer ([#320](https://github.com/TokamakUI/Tokamak/issues/320))
- `TokamakDemo` build failed ([#305](https://github.com/TokamakUI/Tokamak/issues/305))

**Merged pull requests:**

- Add `@dynamicMemberLookup` to `Binding` ([#396](https://github.com/TokamakUI/Tokamak/pull/396)) via [@carson-katri](https://github.com/carson-katri)
- Add `DatePicker` to the `TokamakDOM` module ([#394](https://github.com/TokamakUI/Tokamak/pull/394)) via [@Snowy1803](https://github.com/Snowy1803)
- Use `String(reflecting:)` vs `String(describing:)` ([#391](https://github.com/TokamakUI/Tokamak/pull/391)) via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Clarify the difference between `HTML` and `DynamicHTML` ([#389](https://github.com/TokamakUI/Tokamak/pull/389)) via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Add `_spi(TokamakCore)` to ideally internal public members ([#386](https://github.com/TokamakUI/Tokamak/pull/386)) via [@filip-sakel](https://github.com/filip-sakel)
- Make properties of `CGPoint`, `CGSize` and `CGRect` `var`s instead of `let`s ([#382](https://github.com/TokamakUI/Tokamak/pull/382)) via [@mortenbekditlevsen](https://github.com/mortenbekditlevsen)
- Use immediate scheduler in `TestRenderer` ([#380](https://github.com/TokamakUI/Tokamak/pull/380)) via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Simple Code Coverage analysis ([#378](https://github.com/TokamakUI/Tokamak/pull/378)) via [@mattpolzin](https://github.com/mattpolzin)
- Add checks for metadata state ([#375](https://github.com/TokamakUI/Tokamak/pull/375)) via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Use upstream OpenCombine instead of a fork ([#377](https://github.com/TokamakUI/Tokamak/pull/377)) via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Update JavaScriptKit, OpenCombineJS dependencies ([#376](https://github.com/TokamakUI/Tokamak/pull/376)) via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Clean up metadata reflection code ([#372](https://github.com/TokamakUI/Tokamak/pull/372)) via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Add David Hunt to the list of maintainers ([#373](https://github.com/TokamakUI/Tokamak/pull/373)) via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Refactor environment injection, add a test ([#371](https://github.com/TokamakUI/Tokamak/pull/371)) via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Replace uses of the Runtime library with stdlib ([#370](https://github.com/TokamakUI/Tokamak/pull/370)) via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Use `macos-latest` agent for the GTK build ([#360](https://github.com/TokamakUI/Tokamak/pull/360)) via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Add a benchmark target and a script to run it ([#365](https://github.com/TokamakUI/Tokamak/pull/365)) via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Fix crashes in views with optional content ([#364](https://github.com/TokamakUI/Tokamak/pull/364)) via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Add GTK support for `SecureField` ([#363](https://github.com/TokamakUI/Tokamak/pull/363)) via [@mortenbekditlevsen](https://github.com/mortenbekditlevsen)
- Add support for shadow modifier ([#355](https://github.com/TokamakUI/Tokamak/pull/355)) via [@literalpie](https://github.com/literalpie)
- Two infinite loop fixes ([#359](https://github.com/TokamakUI/Tokamak/pull/359)) via [@foscomputerservices](https://github.com/foscomputerservices)
- Added `TextField` support for GTK using `GtkEntry` ([#361](https://github.com/TokamakUI/Tokamak/pull/361)) via [@mortenbekditlevsen](https://github.com/mortenbekditlevsen)
- Fixed a small issue with re-renderers being dropped ([#356](https://github.com/TokamakUI/Tokamak/pull/356)) via [@foscomputerservices](https://github.com/foscomputerservices)
- Removed an extra space that cause Safari to issue "Invalid value" ([#358](https://github.com/TokamakUI/Tokamak/pull/358)) via [@foscomputerservices](https://github.com/foscomputerservices)
- Add `@mortenbekditlevsen` to the list of maintainers in `README.md` ([#352](https://github.com/TokamakUI/Tokamak/pull/352)) via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Build the GTK renderer on Ubuntu on CI ([#347](https://github.com/TokamakUI/Tokamak/pull/347)) via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Add missing `Link` re-export to TokamakDOM ([#351](https://github.com/TokamakUI/Tokamak/pull/351)) via [@MaxDesiatov](https://github.com/MaxDesiatov)
- GTK shape support WIP ([#348](https://github.com/TokamakUI/Tokamak/pull/348)) via [@mortenbekditlevsen](https://github.com/mortenbekditlevsen)
- Add a "bug report" issue template ([#349](https://github.com/TokamakUI/Tokamak/pull/349)) via [@MaxDesiatov](https://github.com/MaxDesiatov)

# 0.6.1 (6 December 2020)

This release fixes autocomplete in Xcode for projects that depend on Tokamak.

# 0.6.0 (4 December 2020)

This release introduces support for the `Image` view, which can load images bundled as SwiftPM
resources. It also adds the `PreferenceKey` protocol and `preference(key:value:)`,
`onPreferenceChange`, `backgroundPreferenceValue`, `transformPreference`, and
`overlayPreferenceValue` modifiers. Many thanks to [@carson-katri](https://github.com/carson-katri)
and [@j-f1](https://github.com/j-f1) for implementing this!

**Merged pull requests:**

- Add [@kateinoigakukun](https://github.com/kateinoigakukun) to the list of maintainers ([#310](https://github.com/TokamakUI/Tokamak/pull/310)) via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Add `Image` implementation, bump JSKit to 0.9.0 ([#155](https://github.com/TokamakUI/Tokamak/pull/155)) via [@j-f1](https://github.com/j-f1)
- Add Preferences ([#307](https://github.com/TokamakUI/Tokamak/pull/307)) via [@carson-katri](https://github.com/carson-katri)
- Remove unused Dangerfile.swift ([#311](https://github.com/TokamakUI/Tokamak/pull/311)) via [@MaxDesiatov](https://github.com/MaxDesiatov)

# 0.5.3 (28 November 2020)

A bugfix release that fixes `Toggle` values not updated when reset from a binding. Additionally, the
embedded internal implementation of `JSScheduler` is replaced with one from
[`OpenCombineJS`](https://github.com/swiftwasm/OpenCombineJS). This library is a new dependency of
Tokamak used in the DOM renderer.

**Closed issues:**

- `Toggle` value not updated when it's reset from a binding ([#287](https://github.com/TokamakUI/Tokamak/issues/287))

**Merged pull requests:**

- Fix update of `checked` property of checkbox input ([#309](https://github.com/TokamakUI/Tokamak/pull/309)) via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Use latest macOS and Xcode on CI ([#308](https://github.com/TokamakUI/Tokamak/pull/308)) via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Use `JSScheduler` from `OpenCombineJS` package ([#304](https://github.com/TokamakUI/Tokamak/pull/304)) via [@MaxDesiatov](https://github.com/MaxDesiatov)

# 0.5.2 (12 November 2020)

This is a bugfix release that fixes in-tree updates in cases where type of a view changes with
conditional updates. Thanks to [@vi4m](https://github.com/vi4m) for reporting the issue!

**Merged pull requests:**

- Pass sibling to `Renderer.mount`, fix update order ([#301](https://github.com/TokamakUI/Tokamak/pull/301)) via [@MaxDesiatov](https://github.com/MaxDesiatov)

# 0.5.1 (9 November 2020)

A bugfix release to improve compatibility with Xcode autocomplete.

**Merged pull requests:**

- Update Package.resolved ([#300](https://github.com/TokamakUI/Tokamak/pull/300)) via [@kateinoigakukun](https://github.com/kateinoigakukun)
- Allow use of Combine to enable Xcode autocomplete ([#299](https://github.com/TokamakUI/Tokamak/pull/299)) via [@MaxDesiatov](https://github.com/MaxDesiatov)

# 0.5.0 (9 November 2020)

This is a compatibility release with small feature additions. Namely the `Link` view is now available,
and our JavaScriptKit dependency has been updated. The latter change now allows you to open
`Package.swift` package manifests of your Tokamak projects with working auto-complete in Xcode.
Also, our dark mode implementation now more closely follows SwiftUI behavior.

Many thanks to [@carson-katri](https://github.com/carson-katri) and
[@kateinoigakukun](https://github.com/kateinoigakukun) for their contributions to this release!

**Closed issues:**

- Can't build Tokamak project - carton dev command ([#296](https://github.com/TokamakUI/Tokamak/issues/296))
- Colors should change depending on light/dark color scheme ([#290](https://github.com/TokamakUI/Tokamak/issues/290))
- Pattern for handling global dom events ([#284](https://github.com/TokamakUI/Tokamak/issues/284))
- 0.4.0 upgrade / regression? ([#283](https://github.com/TokamakUI/Tokamak/issues/283))

**Merged pull requests:**

- Xcode compatibility ([#297](https://github.com/TokamakUI/Tokamak/pull/297)) via [@kateinoigakukun](https://github.com/kateinoigakukun)
- Allow tests to be run on macOS ([#295](https://github.com/TokamakUI/Tokamak/pull/295)) via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Add Link view, update JavaScriptKit to 0.8.0 ([#276](https://github.com/TokamakUI/Tokamak/pull/276)) via [@carson-katri](https://github.com/carson-katri)
- Add `AnyColorBox` and `AnyFontBox` ([#291](https://github.com/TokamakUI/Tokamak/pull/291)) via [@carson-katri](https://github.com/carson-katri)
- Replace Danger with SwiftLint to improve warnings ([#293](https://github.com/TokamakUI/Tokamak/pull/293)) via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Use v5.3 tag of `swiftwasm-action` in `ci.yml` ([#292](https://github.com/TokamakUI/Tokamak/pull/292)) via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Add @carson-katri and @kateinoigakukun to `FUNDING.yml` ([#289](https://github.com/TokamakUI/Tokamak/pull/289)) via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Add `URLHashDemo` w/ `window.onhashchange` closure ([#288](https://github.com/TokamakUI/Tokamak/pull/288)) via [@MaxDesiatov](https://github.com/MaxDesiatov)

# 0.4.0 (30 September 2020)

This is mainly a bugfix and compatibility release with a small feature addition. Namely, `Slider`
view is introduced in the DOM renderer, and binding updates for SVG elements are working now. During
this development cycle efforts of our team were devoted to recently released [JavaScriptKit
0.7](https://github.com/swiftwasm/JavaScriptKit/releases/tag/0.7.0) and [`carton`
0.6](https://github.com/swiftwasm/carton/releases/tag/0.6.0). Both of those releases are pretty big
updates that improve developer experience significantly, and this version of Tokamak requires those
as minimum versions.

Many thanks to [@j-f1](https://github.com/j-f1) and
[@kateinoigakukun](https://github.com/kateinoigakukun) for their contributions to these updates!

**Closed issues:**

- HTML + Binding ([#278](https://github.com/TokamakUI/Tokamak/issues/278))

**Merged pull requests:**

- Fix compatibility with JavaScriptKit 0.7 ([#281](https://github.com/TokamakUI/Tokamak/pull/281))
  via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Re-export `HTML` type in `TokamakDOM` ([#275](https://github.com/TokamakUI/Tokamak/pull/275)) via
  [@kateinoigakukun](https://github.com/kateinoigakukun)
- Use setAttribute, not properties to fix SVG update
  ([#279](https://github.com/TokamakUI/Tokamak/pull/279)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Allow non-body mount host node ([#271](https://github.com/TokamakUI/Tokamak/pull/271)) via
  [@kateinoigakukun](https://github.com/kateinoigakukun)
- Add missing JavaScriptKit import to `README.md`
  ([#265](https://github.com/TokamakUI/Tokamak/pull/265)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Fix the sizing of sliders ([#268](https://github.com/TokamakUI/Tokamak/pull/268)) via
  [@j-f1](https://github.com/j-f1)
- Add `Slider` implementation ([#228](https://github.com/TokamakUI/Tokamak/pull/228)) via
  [@j-f1](https://github.com/j-f1)
- Remove Xcode 12 warning from README.md ([#264](https://github.com/TokamakUI/Tokamak/pull/264)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)

# 0.3.0 (19 August 2020)

This release improves compatibility with the SwiftUI API and fixes bugs in our WebAssembly/DOM renderer, included but not limited to:

- support for `App`/`Scene` lifecycle;
- `ColorScheme` detection and environment setting;
- dark mode styles;
- `@StateObject` property wrapper implementation;
- `SidebarListStyle`, `ButtonStyle`, `GeometryProxy` types;
- `NavigationView` and `GeometryReader` views.

Additionally, new `TokamakStaticHTML` renderer was added that supports rendering stateless views into static HTML that doesn't include any JavaScript or WebAssembly dependencies. This is useful for static websites and in the future could be used together with `TokamakDOM` for server-side rendering.

Tokamak 0.3.0 now requires 5.3 snapshots of SwiftWasm, which in general should be more stable than the development snapshots that were previously used, and is also compatible with Xcode 12 betas. If you have a `.swift-version` file in your project, you should specify `wasm-5.3-SNAPSHOT-2020-07-27-a` in it or a later 5.3 snapshot, otherwise `carton` 0.5 selects a compatible 5.3 snapshot for you automatically. Allowing `carton` to select a default snapshot is the recommended approach, so in general we recommend avoiding `.swif-version` files in projects that use Tokamak.

Many thanks to [@carson-katri](https://github.com/carson-katri), [@j-f1](https://github.com/j-f1),
and [@Outcue](https://github.com/Outcue) for their contributions to this release.

The complete list of changes included in this release is available below.

**Closed issues:**

- Command "carton dev" failed ([#258](https://github.com/swiftwasm/Tokamak/issues/258))
- Dark mode detection causes crashes in Safari
  ([#245](https://github.com/swiftwasm/Tokamak/issues/245))
- Add dark color scheme style ([#237](https://github.com/swiftwasm/Tokamak/issues/237))
- Establish App lifecycle as the only way to start rendering
  ([#224](https://github.com/swiftwasm/Tokamak/issues/224))
- Runtime issues with dynamic properties in `App` types
  ([#222](https://github.com/swiftwasm/Tokamak/issues/222))
- `List` appearance changes when reloaded ([#212](https://github.com/swiftwasm/Tokamak/issues/212))
- List scrolling does not work on Firefox 78 on macOS
  ([#211](https://github.com/swiftwasm/Tokamak/issues/211))
- Scrolling broken when `List` is child of `NavigationView`
  ([#208](https://github.com/swiftwasm/Tokamak/issues/208))
- `Rectangle` frame is not being set properly
  ([#185](https://github.com/swiftwasm/Tokamak/issues/185))
- Implement `SidebarListStyle` ([#180](https://github.com/swiftwasm/Tokamak/issues/180))
- Implement `GeometryReader`/`GeometryProxy`
  ([#176](https://github.com/swiftwasm/Tokamak/issues/176))
- `@StateObject` support ([#158](https://github.com/swiftwasm/Tokamak/issues/158))
- NavigationView/NavigationLink ([#129](https://github.com/swiftwasm/Tokamak/issues/129))

**Merged pull requests:**

- Set versions of dependencies in `Package.swift`
  ([#262](https://github.com/swiftwasm/Tokamak/pull/262)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Implement `StateObject` property wrapper ([#260](https://github.com/swiftwasm/Tokamak/pull/260))
  via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Fix `NavigationView` broken state after re-render
  ([#259](https://github.com/swiftwasm/Tokamak/pull/259)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Add `GeometryReader` implementation ([#239](https://github.com/swiftwasm/Tokamak/pull/239)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Add default dark styles for Views ([#241](https://github.com/swiftwasm/Tokamak/pull/241)) via
  [@carson-katri](https://github.com/carson-katri)
- Link to the renderers guide from `README.md`
  ([#251](https://github.com/swiftwasm/Tokamak/pull/251)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Use the latest 5.3 snapshot in `.swift-version`
  ([#252](https://github.com/swiftwasm/Tokamak/pull/252)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Fix color scheme observer crashes in Safari
  ([#249](https://github.com/swiftwasm/Tokamak/pull/249)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Update to the latest version of SwiftFormat
  ([#250](https://github.com/swiftwasm/Tokamak/pull/250)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Split demo list into sections ([#243](https://github.com/swiftwasm/Tokamak/pull/243)) via
  [@j-f1](https://github.com/j-f1)
- Remove some `AnyView` in the `List` implementation
  ([#246](https://github.com/swiftwasm/Tokamak/pull/246)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Add `_targetRef` and `_domRef` modifiers ([#240](https://github.com/swiftwasm/Tokamak/pull/240))
  via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Add `ColorScheme` environment ([#136](https://github.com/swiftwasm/Tokamak/pull/136)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Add `redacted` modifier ([#232](https://github.com/swiftwasm/Tokamak/pull/232)) via
  [@carson-katri](https://github.com/carson-katri)
- Add Static HTML Renderer and Documentation ([#204](https://github.com/swiftwasm/Tokamak/pull/204))
  via [@carson-katri](https://github.com/carson-katri)
- Fix tests, move `DefaultButtonStyle` to TokamakCore
  ([#234](https://github.com/swiftwasm/Tokamak/pull/234)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Remove `DefaultApp`, make `DOMRenderer` internal
  ([#227](https://github.com/swiftwasm/Tokamak/pull/227)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Add basic `ButtonStyle` implementation ([#214](https://github.com/swiftwasm/Tokamak/pull/214)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Make reconciler tests build and run on macOS
  ([#229](https://github.com/swiftwasm/Tokamak/pull/229)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Fix environment changes causing remounted scenes with lost state
  ([#223](https://github.com/swiftwasm/Tokamak/pull/223)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Add `DefaultApp` type to simplify `DOMRenderer.init`
  ([#217](https://github.com/swiftwasm/Tokamak/pull/217)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Implement `SidebarListStyle` ([#210](https://github.com/swiftwasm/Tokamak/pull/210)) via
  [@Outcue](https://github.com/Outcue)
- Unify code of `MountedApp`/`MountedCompositeView`
  ([#219](https://github.com/swiftwasm/Tokamak/pull/219)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Generalize style and environment in `DOMRenderer`
  ([#215](https://github.com/swiftwasm/Tokamak/pull/215)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Implement `DynamicProperty` ([#213](https://github.com/swiftwasm/Tokamak/pull/213)) via
  [@carson-katri](https://github.com/carson-katri)
- Warn against beta versions of Xcode in README.md
  ([#207](https://github.com/swiftwasm/Tokamak/pull/207)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Fix typo in `TokamakDemo.swift` ([#206](https://github.com/swiftwasm/Tokamak/pull/206)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Update "Requirements" and "Getting started" README sections
  ([#205](https://github.com/swiftwasm/Tokamak/pull/205)) via
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Initial `NavigationView` implementation ([#130](https://github.com/swiftwasm/Tokamak/pull/130))
  via [@j-f1](https://github.com/j-f1)
- Add SwiftUI App Lifecycle ([#195](https://github.com/swiftwasm/Tokamak/pull/195)) via
  [@carson-katri](https://github.com/carson-katri)

# 0.2.0 (21 July 2020)

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

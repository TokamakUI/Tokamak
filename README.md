# Gluon

## React-like framework for native UI written in pure Swift 🛠⚛️📲

[![CI Status](https://img.shields.io/travis/MaxDesiatov/Gluon.svg?style=flat)](https://travis-ci.org/MaxDesiatov/Gluon)
[![Coverage](https://img.shields.io/codecov/c/github/MaxDesiatov/Gluon/master.svg?style=flat)](https://codecov.io/gh/maxdesiatov/Gluon)
<!--
[![Version](https://img.shields.io/cocoapods/v/Gluon.svg?style=flat)](https://cocoapods.org/pods/Gluon)
[![License](https://img.shields.io/cocoapods/l/Gluon.svg?style=flat)](https://cocoapods.org/pods/Gluon)
[![Platform](https://img.shields.io/cocoapods/p/Gluon.svg?style=flat)](https://cocoapods.org/pods/Gluon)
-->

Gluon provides a declarative, testable and scalable API for building UI
components backed by fully native views. You can use it for your new iOS apps or
add to existing apps with little effort and without rewriting the rest of the
code or changing the app's overall architecture.

Gluon recreates [React's Hooks API](https://reactjs.org/docs/hooks-intro.html)
improving it with Swift's strong type system, high performance and efficient
memory management thanks to being compiled to a native binary.

When compared to standard UIKit MVC or other patterns built on top of
it (MVVM, MVP, VIPER etc), Gluon provides:

* **Declarative [DSL](https://en.wikipedia.org/wiki/Domain-specific_language)
for native UI**: no more conflicts caused by Storyboards, no template languages 
or XML. Describe UI of your app concisely in Swift and get views native to 
iOS with full support for accessibility, auto layout and native navigation gestures.

* **Easy to use one-way data binding**: tired of `didSet`, delegates,
notifications or KVO? Component's UI is automatically updated based on
state changes.

* **Clean composable architecture**: components can be passed to other
components as children with an established API focused on code reuse. You can
easily embed Gluon components within your existing UIKit code or vice versa:
expose that code as Gluon components. No need to decide whether you should
subclass `UIView` or `UIViewController` to make your UI composable.

* **Off-screen rendering for unit-tests**: no need to maintain slow and flaky
UI tests that render everything on a simulator screen and simulate actual
touch events. All of UI logic written with Gluon can be tested off-screen
with tests completing in a fraction of a second.

* **Platform-independent core**: our main goal is to eventually support as many
platforms as possible. Starting with iOS and UIKit, we plan to add renderers
for macOS/AppKit, WebAssembly/DOM and native Android in future versions. As
the core API is cross-platform, UI components written with Gluon won't need to
change to become available on newly added platforms unless you need UI logic
specific to a device or OS.

* **Architecture proven to work**: React has been available for years and
gained a lot of traction and is still growing. We've seen so many apps
successfully rebuilt with it and heard positive feedback on React itself, but
a lot of complaints about overreliance on JavaScript. Gluon makes architecture
of React with its established patterns available to you in Swift.

## Table of contents

  * [Example code](#example-code)
  * [Fundamental concepts](#fundamental-concepts)
      * [Props](#props)
      * [Children](#children)
      * [Nodes](#nodes)
      * [Components](#components)
      * [Hooks](#hooks)
      * [Renderers](#renderers)
  * [Example project](#example-project)
  * [Requirements](#requirements)
  * [FAQ](#faq)
  * [Acknowledgments](#acknowledgments)
  * [Contributing](#contributing)
  * [Maintainers](#maintainers)
  * [License](#license)

## Example code

An example of a Gluon component that binds a button to a label, embedded
within an existing UIKit app, looks like this:

```swift
import Gluon
import GluonUIKit

struct Counter: LeafComponent {
  struct Props: Equatable {
    let countFrom: Int
  }

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let count = hooks.state(props.countFrom)

    return StackView.node(.init(axis: .vertical,
                                distribution: .fillEqually,
                                Style(Edges.equal(to: .parent))), [
      Button.node(.init(onPress: Handler { count.set { $0 + 1 } }),
                  "Increment"),
      Label.node(.init(alignment: .center), "\(count.value)")
    ])
  }
}

final class ViewController: GluonViewController {
  override var node: AnyNode {
    return Counter.node(.init(countFrom: 1))
  }
}
```

![Counter component](GluonCounter.gif)

## Fundamental concepts

We try to keep Gluon's API as simple as possible and the core algorithm with
supporting protocols/structures currently fit in only ~600 lines of code. It's
all built upon a few basic concepts:

### Props

`Props` describe a "configuration" of what you'd like to see on user's screen.
`Props` are immutable and
[`Equatable`](https://developer.apple.com/documentation/swift/equatable), which
allows us to observe when they change. You wouldn't ever need to provide your
own `Equatable` implementation for `Props` as Swift compiler is able to generate
one for you [automatically behind the
scenes](https://github.com/apple/swift-evolution/blob/master/proposals/0185-synthesize-equatable-hashable.md).
Here's a simple `Props` struct you could use for your own component like
`Counter` from the example above:

```swift
struct Props: Equatable {
  let countFrom: Int
}
```

### Children

Sometimes "configuration" is described in a tree-like fashion. For example, a
list of views contains an array of subviews, which themselves can contain other
subviews. In Gluon this is called `Children`, which behave similar to `Props`,
but are important enough to be treated separately. `Children` are also immutable
and `Equatable`, which allows us to observe those for changes too.

### Components

`Component` is a protocol, which couples given `Props` and `Children` on screen
and provides some declaration how these are rendered on screen:

```swift
protocol Component {
  associatedtype Props: Equatable
  associatedtype Children: Equatable
}
```

(Don't worry if you don't know what `associatedtype` means, it's only a simple
requirement for components to provide these types and make them `Equatable`. If
you do know what a [PAT](https://www.youtube.com/watch?v=XWoNjiSPqI8) is, you
also shouldn't worry. 😄 Gluon's API is built specifically to hide "sharp edges"
of PATs from the public API and to make it easy to use without requiring
advanced knowledge of Swift. This is similar to what [Swift standard
library](https://developer.apple.com/documentation/swift/swift_standard_library/)
has done, which is built on top of PATs but stays flexible and ergonomic).

### Nodes

A node is a container for `Props`, `Children` and a type conforming to
`Component` rendering this "configuration". If you're familiar with React, nodes
in Gluon correspond to [elements in
React](https://reactjs.org/docs/glossary.html#elements). When `Children` is an
array of nodes, we can indirectly form a tree describing the app's UI.
Corollary, nodes are immutable and `Equatable`. You'd only need to use the
standard `AnyNode` type provided by Gluon:

```swift
struct AnyNode: Equatable {
  // ... `Props` and `Children` stored here by Gluon as private properties 
}
```
 
Here's an example of an array of nodes used as `Children` in the standard
`StackView` component provided by Gluon, which describe subviews of the stack
view.

```swift
struct StackView: Component {
  struct Props: Equatable {
    // ...
  }
  typealias Children = [AnyNode]
}
```

For every component Gluon provides an easy way to create a node for it 
coupled with given props and children:

```swift
// this extension and its `node` function are defined for you by Gluon
extension Component {
  static func node(_ props: Props, _ children: Children) -> AnyNode {
    // ...
  }
}
```

One of the most simple components is a [pure
function](https://en.wikipedia.org/wiki/Pure_function) taking `Props` and
`Children` as an argument and returning a node tree as a result:

```swift
protocol PureComponent: Component {
  // this is the function you define for your own components, 
  // Gluon takes care of the rest
  static func render(props: Props, children: Children) -> AnyNode
}
```

Gluon calls `render` on your components when their `Props` or `Children` passed
from parent components change. You don't ever need to call `render` yourself,
pass different values as props or children to nodes returned from parent
`render` and Gluon will update only those views on screen that need to be
updated. 

Note that `render` function does not return *other components*, it returns
*nodes* that *describe other components*. It's a very important distiction,
which allows Gluon to stay efficient and to avoid updating deep trees of
components.

Some of your components wouldn't need `Children` at all, for those Gluon
provides a `PureLeafComponent` helper protocol that allows you to implement only
a single function with a simpler signature:

```swift
// Helpers provided by Gluon:

struct Null: Equatable {}

protocol PureLeafComponent: PureComponent where Children == Null {
  static func render(props: Props) -> AnyNode
}

extension PureLeafComponent {
  static func render(props: Props, children: Children) -> AnyNode {
    return render(props: props)
  }
}
```

### Hooks

Quite frequently you need components that are stateful or cause some other
[side effects](https://en.wikipedia.org/wiki/Side_effect_(computer_science)).
`Hooks` provide a clear separation between declarative components and other 
imperative code, such as state management, file I/O, networking etc.

The standard protocol `CompositeComponent` in Gluon gets `Hooks` injected into
`render` function as an argument.

```swift
protocol CompositeComponent: Component {
  static func render(
    props: Props,
    children: Children,
    hooks: Hooks
  ) -> AnyNode
}
```

In fact, the standard `PureComponent` is a special case of a `CompositeComponent`
that doesn't use `Hooks` during rendering:

```swift
// Helpers provided by Gluon:

protocol PureComponent: CompositeComponent {
  static func render(props: Props, children: Children) -> AnyNode
}

extension PureComponent {
  static func render(
    props: Props,
    children: Children,
    hooks: Hooks
  ) -> AnyNode {
    return render(props: props, children: children)
  }
}
```

One of the simplest hooks is `state`. It allows a component to have its own
state and to be updated when the state changes. We've seen it used in the
`Counter` example:

```swift
struct Counter: LeafComponent {
  // ...
  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let count = hooks.state(1)
    // ...
  }
}
```

It returns a very simple state container, which on initial call of `render`
contains `1` as a value and values passed to `count.set(_: Int)` on subsequent
updates:

```swift
// values of this type are returned by `hooks.state`
struct State<T> {
  let value: T

  // set the state to a value you already have
  func set(_ value: T)

  // or update the state with a pure function
  func set(_ updater: (T) -> T)
}
```

Note that `set` functions are not `mutating`, they never update the component's
state in-place synchronously, but only schedule an update with Gluon at a later
time. A call to `render` is only scheduled on the component that obtained this
state with `hooks.state`. 

When you need state changes to update any of the descendant components, you can
pass the state value within props or children of nodes returned from `render`.
In `Counter` component the label's content is "bound" to `count` this way:

```swift
struct Counter: LeafComponent {
  static func render(props: Null, hooks: Hooks) -> AnyNode {
    let count = hooks.state(1)

    return StackView.node([
        Button.node(.init(onPress: Handler { count.set { $0 + 1 } }), 
                    "Increment"),
        Label.node("\(count.value)"),
    ])
  }
}
```

Hooks provide a great way to compose side effects and also to keep them separate
from your component code. You can always create your own hook reusing existing
ones: just add it to your `extension Hooks` wherever works best for you.

### Renderers

When mapping Gluon's architecture to what's previosly been established in iOS,
`Component` corresponds to a "view-model" layer, while `Hooks` provide a reusable
"controller" layer. A `Renderer` is a "view" layer in these terms, but it's
fully managed by Gluon. Not only this greatly simplifies the code of your
components and allows you to make it declarative, it also completely decouples
platform-specific code.  Note that `Counter` component above doesn't contain a
single type from `UIKit` module, although the component itself is passed to a
specific `UIKitRenderer` to make it available in an app using `UIKit`. On other
platforms you could use a different renderer, while the component code could
stay the same if its behavior doesn't need to change for that environment.
Otherwise you can adjust component's behavior via `Props` and pass different
"initializing" props depending on the renderer's platform.

Providing renderers for other platforms in the future is one of our top
priorities. Imagine an `AppKitRenderer` that allows you to render the same
component on macOS without any changes applied to the component code and without
requiring [Marzipan](https://www.imore.com/marzipan)!

## Example project

To run the example project, clone the repo, and run `pod install` from the
[`Example`](https://github.com/MaxDesiatov/Gluon/tree/master/Example) directory
first. Then you can open `Example/Gluon.xcworkspace` and run the main 
executable target `Gluon-Example`.

## Requirements

* iOS 10.0 or later
* Xcode 10.1
* Swift 4.2

<!--

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Swift and
Objective-C Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

Navigate to the project directory and create `Podfile` with the following command:

```bash
$ pod install
```

Inside of your `Podfile`, specify the `Gluon` pod:

```ruby
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'YourApp' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Test
  pod 'Gluon', '~> 0.1'
end
```

Then, run the following command:

```bash
$ pod install
```

Open the the `YourApp.xcworkspace` file that was created. This should be the
file you use everyday to create your app, instead of the `YourApp.xcodeproj`
file.

-->

## FAQ

### What are "Rules of Hooks"?

Hooks are a great way to inject state and other side effects into pure
functions. In some sense, you could consider Hooks an emulation of [indexed
monads](https://kseo.github.io/posts/2017-01-12-indexed-monads.html) or
[algebraic effects](http://www.eff-lang.org), which served as [inspiration for
Hooks in
React](https://reactjs.org/docs/hooks-faq.html#what-is-the-prior-art-for-hooks).
Unfortunately, due to Swift's current limitations, we can't express monads or
algebraic effects natively, so Hooks need a few restrictions applied to make it
work. Similar restrictions are also applied to [Hooks in
React](https://reactjs.org/docs/hooks-rules.html):

1. You can call Hooks from `render` function of any component. 👍
2. You can call Hooks from your custom Hooks (defined by you in an `extension`
   of `Hooks`). 🙌
3. Don't call Hooks from a loop, condition or nested function/closure. 🚨
4. Don't call Hooks from any function that's not a `static func render` on a
   component or not a custom Hook. ⚠️

In a future version Gluon will provide a linter able to catch violations of
Rules of Hooks at compile time.

### Why do Rules of Hooks exist?

[Same as
React](https://reactjs.org/docs/hooks-faq.html#how-does-react-associate-hook-calls-with-components),
Gluon maintains an array of "memory cells" for every stateful component to hold
the actual state. It needs to distinguish one Hooks call from another to map
those to corresponding cells during execution of a `render` function of your
component. Consider this:

```swift
struct ConditionalCounter: LeafComponent {
  typealias Props = Null

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    // this code won't work as expected as it violates Rule 3:
    // > Don't call Hooks from a condition
    
    // state stored in "memory cell" 1
    let condition = hooks.state(false) 
    if condition {
      // state stored in "memory cell" 2
      count = hooks.state(0) 
    } else {
      // state, which should be stored in "memory cell" 3, 
      // but will be actually queried from "memory cell" 2
      count = hooks.state(42) 
    }
    
    return StackView.node([
      Switch.node(.init(value: condition.value,
                        valueHandler: Handler(condition.set)))
      Button.node(.init(onPress: Handler { count.set { $0 + 1 } }),
                  "Increment"),
      Label.node("\(count.value)"),
    ])
  }
}
```

How does Gluon renderer know on subsequent calls to `DoubleCounter.render` which
state you're actually addressing? It relies on the order of those calls, so if
the order dynamically changes from one rendering to another, you could
unexpectedly get a value of the one state cell, when you expected a value of
a different state cell. 

We encourage you to keep any hooks logic at the top level of a `render`
definition, which makes all side effects of a component clear upfront and is a
good practice anyway. If you do need conditions or loops applied, you can always
create a separate component and return a node conditionally or an array of nodes
for this new child component from `render` of a parent component. The fixed 
version of `ConditionalCounter` would look like this:

```swift
struct ConditionalCounter: LeafComponent {
  typealias Props = Null

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    // this works as expected
    let condition = hooks.state(false)
    let count1 = hooks.state(0)
    let count2 = hooks.state(42)

    let value = (condition ? count1 : count2).value

    return StackView.node([
      Switch.node(.init(value: condition.value,
                        valueHandler: Handler(condition.set)))
      Button.node(.init(onPress: Handler { count.set { $0 + 1 } }),
                  "Increment"),
      Label.node("\(count.value)"),
    ])
  }
}
```

### Why does Gluon use value types and protocols instead of classes?

Swift developers focused on GUI might be used to classes thanks to abundance of
class hierarchies in `UIKit` and `AppKit` (although [benefits of composition
over
inheritance](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CocoaFundamentals/AddingBehaviortoaCocoaProgram/AddingBehaviorCocoa.html#//apple_ref/doc/uid/TP40002974-CH5-SW22)
were previously highlighted by Apple). Unfortunately, while `UIKit` is a
relatively fresh development, it still closely follows many patterns used in
`AppKit`, which was itself [built in late
80s](https://en.wikipedia.org/wiki/NeXTSTEP). Both of these were developed with
Objective-C in mind, years before Swift became public and [protocol-oriented
patterns](https://developer.apple.com/videos/play/wwdc2015/408/) were
established.

One of the main goals of Gluon is to build a UI framework that feels native to
Swift. Gluon's API brings these benefits when compared to class-based APIs:

- no need to [subclass `NSObject` to conform to commonly used
  protocols](https://stackoverflow.com/questions/31754366/swift-my-custom-uitableviewdatasource-class-thinks-it-doesnt-conform-to-protoc);
- no need to use `override` and to remember to call `super`;
- no need for `required init`, `convenience init` or to be concerned with strict
  class initialization rules;
- you can't create a reference cycle with immutable values, no need for
  [`weakSelf/strongSelf`
  dance](https://stackoverflow.com/questions/21113963/is-the-weakself-strongself-dance-really-necessary-when-referencing-self-inside-a)
  when using callbacks;
- you don't need to worry about modifying an object in a different scope
  accidentaly captured by reference: immutable values are implicitly copied
  and most of the copies are removed by the compiler during optimization;
- focus on composition over inheritance: no need to subclass `UIViewController`
  or `UIView` and to worry about all of the above when you only need simple 
  customization;
- focus on functional and declarative programming, while still allowing to use
  imperative code when needed: value types guarantee lack of unexpected
  side effects in pure functions.

### Is there anything like [JSX](https://reactjs.org/docs/jsx-in-depth.html) available for Gluon?

At the moment the answer is no, but we find that Gluon's API allows you to
create nodes much more concisely when compared to `React.createElement` syntax.
In fact, with Gluon's `.node` API you don't need closing element tags you'd have 
to write with JSX. E.g. compare this:

```swift
Label.node("label!")
```

to this:

```jsx
<Label>label!</Label>
```

We do agree that there's an overhead of `.init` for props and a requirement of
props initializer arguments to be ordered. For the latter, we have a helpful
convention in Gluon that all named arguments to props initializers should be
ordered alphabetically.

The main problem is that currently there's no easily extensible Swift parser or
a macro system available that would allow something like JSX to be used for
Gluon. As soon is it becomes easy to implement, we'd definitely consider it as
an option.

### Why is `render` function `static` on `Component` protocol?

With an alternative approach to API design of a framework like this we could
define components as plain functions, which wouldn't need to be `static`:

```swift
func counter(hooks: Hooks) -> AnyNode {
  // ...
}
```

The problem here is that we need equality comparison on components to be able
to define `Equatable` on `AnyNode`. This isn't available for plain functions:

```swift
let x = counter
let y = counter

// won't compile
x == y

// won't compile: reference equality is also not defined on functions,
// even though functions are reference types ¯\_(ツ)_/¯ 
x === y
```

Protocols and structs with `static` functions allow us to work around this and
to formalise an hierarchy of different kinds of components with protocols and
`Equatable` constraints:

```swift
// equality comparison is available for types
struct Counter {
  static func render(hooks: Hooks) -> AnyNode { 
    // ...
  }
}


// Gluon does something like this internally for your components,
// consider following a pseudocode:
let xComponent = Counter.self
let yComponent = OtherComponent.self

var rendered: AnyNode?
if xComponent != yComponent {
  rendered = xComponent.render()
}
```

We could remove `static` from `render` on `Component` protocol, but this makes
possible adding and referencing instance properties from a non-`static` version
of `render`. Components could become inadvertently stateful that way, hiding the
fact that components are actually functions, not instances. Consider this
hypothetical API:

```swift
struct Counter {
  // this makes `Counter` component stateful,
  // but prevents observing state changes
  var count = 0

  // no `static` here, which makes `var` above accessible
  func render() -> AnyNode {
    return Label.node("\(count)")
  }
}
```

Now there's direct access to component's state, but we aren't able to easily
schedule updates of the component tree when this state changes. We could require
authors of components to implement
[`didSet`](https://www.hackingwithswift.com/read/8/5/property-observers-didset)
on every instance property, but this is cumbersome and hard to enforce.
Marking `render` as `static` makes it harder to introduce unobservable local
state, while intended local state is managed with `Hooks`.


## Acknowledgments

* Thanks to the [Swift Core Team](https://swift.org/community/) for
  building one of the best programming languages available!
* Thanks to [React
  people](https://reactjs.org/docs/hooks-faq.html#what-is-the-prior-art-for-hooks)
  for building a UI framework that is practical and elegant, while keeping it
  usable with JavaScript at the same time. 😄
* Thanks to [Render](https://github.com/alexdrone/Render),
  [ReSwift](https://github.com/ReSwift/ReSwift), [Katana
  UI](https://github.com/BendingSpoons/katana-ui-swift) and
  [Komponents](https://github.com/freshOS/Komponents) for inspiration!

## Contributing

This project adheres to the [Contributor Covenant Code of
Conduct](https://github.com/MaxDesiatov/Gluon/blob/master/CODE_OF_CONDUCT.md).
By participating, you are expected to uphold this code. Please report
unacceptable behavior to conduct@gluon.sh.

## Maintainers

[Max Desiatov](https://desiatov.com), [Matvii
Hodovaniuk](https://matvii.hodovani.uk)

## License

Gluon is available under the Apache 2.0 license. See the
[LICENSE](https://github.com/MaxDesiatov/Gluon/blob/master/LICENSE) file for
more info.

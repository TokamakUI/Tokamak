# Frequently Asked Questions

## Why does Tokamak use HTML/CSS for rendering in the browser?

HTML/CSS has a benefit of built-in accessibility support. Other rendering systems in the browser (such as Canvas or WebGL/WebGPU)
that bypass HTML/CSS would have to reimplement accessibility from scratch, with all the downsides of increased binary
size and performance overhead. With HTML/CSS we can rely on what's already included in the browser and has been tested and polished
by hundreds of engineers over the decades of browser development.

Additionally, we can rely on optimized CSS layout algorithms where possible. This also unlocks more use-cases for Tokamak, such as
[static HTML generation](https://github.com/TokamakUI/TokamakPublish) and [server-side rendering](https://github.com/TokamakUI/TokamakVapor).

At the same time, Tokamak has [a new layout system in development](https://github.com/TokamakUI/Tokamak/pull/472) that accesses
DOM directly for layout calculations, bypassing CSS for a lot (or potentially all) of its algorithms.

## Does the word Tokamak mean anything? Why is it called this?

The project was originally inspired by [React](https://reactjs.org), which utilizes a model of an atom in its logo,
apparently as a reference to nuclear reactors. [Токамак](https://en.wikipedia.org/wiki/Tokamak) is a nuclear fusion reactor, and 
the word itself is roughly an abbreviation of "**to**roidal **cha**mber with **ma**gnetic **c**oils".

##  What's the history behind it?

The first commit to this project was made in September 2018, 9 months before SwiftUI was publicly announced. The original maintainer of
it had a feeling it would be beneficial to replace UIKit and AppKit with a declarative UI framework. It originally started
as a port of the [React API](https://reactjs.org/) to Swift. The opinion of the original maintainer was that React was a pretty good
solution at that time and was adopted widely enough for people to be acquainted with the general idea. The architecture of React
was quite modular, and it had a well-documented reconciler algorithm that worked independently from platform-specific renderers.

The plan was to build something similar to the React API in Swift with renderers for macOS and iOS, and then potentially for
WebAssembly, Android, and Windows. Shortly after a short series of [0.1 releases with the React
API](https://github.com/swiftwasm/Tokamak/blob/0.1.2/README.md), Tokamak for iOS/macOS was [sherlocked](https://en.wikipedia.org/wiki/Sherlock_(software)#Sherlocked_as_a_term) by
SwiftUI at WWDC 2019. It no longer made sense to continue developing it in that form for Apple's platforms, even though it could
still be useful for other platforms. The original maintainer thought it would be hard to convince Swift developers to use something
that doesn't look like SwiftUI, at least as long as the majority of Swift developers target Apple's platforms. 

In addition to SwiftUI and React, we'd like to credit [SwiftWebUI](https://github.com/SwiftWebUI/SwiftWebUI) for reverse-engineering
some of the bits of SwiftUI and kickstarting the front-end Swift ecosystem for the web. [Render](https://github.com/alexdrone/Render),
[ReSwift](https://github.com/ReSwift/ReSwift), [Katana UI](https://github.com/BendingSpoons/katana-ui-swift), and
[Komponents](https://github.com/freshOS/Komponents) declarative UI frameworks served as additional inspiration for the project.

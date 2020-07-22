// Copyright 2020 Tokamak contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Created by Max Desiatov on 07/04/2020.
//

public protocol View {
  associatedtype Body: View

  @ViewBuilder var body: Self.Body { get }
}

extension Never {
  public var body: Never {
    neverBody("Never")
  }
}

extension Never: View {}

/// A `View` type that renders with subviews, usually specified in the `Content` type argument
public protocol ParentView {
  var children: [AnyView] { get }
}

/// A `View` type that is not rendered, but "flattened" rendering all its children instead.
protocol GroupView: ParentView {}

/** The distinction between "host" (truly primitive) and "composite" (that have meaningful `body`)
 views is made in the reconciler in `TokamakCore` based on their `body` type, host views have body
 type `Never`. `ViewDeferredToRenderer` allows renderers to override that per-platform and render
 host views as composite by providing their own `deferredBody` implementation.
 */
public protocol ViewDeferredToRenderer {
  var deferredBody: AnyView { get }
}

/// Calls `fatalError` with an explanation that a given `type` is a primitive `View`
public func neverBody(_ type: String) -> Never {
  fatalError("\(type) is a primitive `View`, you're not supposed to access its `body`.")
}

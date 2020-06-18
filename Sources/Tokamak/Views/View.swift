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

  var body: Self.Body { get }
}

extension Never: View {
  public typealias Body = Never
}

public extension View where Body == Never {
  var body: Never { fatalError() }
}

/// A `View` type that renders with subviews, usually specified in the `Content` type argument
public protocol ParentView {
  var children: [AnyView] { get }
}

/// A `View` type that is not rendered, but "flattened" rendering all its children instead.
protocol GroupView: ParentView {}

public protocol ViewDeferredToRenderer {
  var deferredBody: AnyView { get }
}

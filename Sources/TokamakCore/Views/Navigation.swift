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
//  Created by Jed Fox on 06/30/2020.
//

public struct NavigationView<Content>: View where Content: View {
  let content: Content

  @State public var selectedId: Double?

  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  public var body: Never {
    neverBody("NavigationView")
  }
}

public struct NavigationLink<Label, Destination>: View where Label: View, Destination: View {
  let destination: Destination
  let label: Label

  public init(destination: Destination, @ViewBuilder label: () -> Label) {
    self.destination = destination
    self.label = label()
  }

  /// Creates an instance that presents `destination` when active.
  // public init(destination: Destination, isActive: Binding<Bool>, @ViewBuilder label: () -> Label)

  /// Creates an instance that presents `destination` when `selection` is set
  /// to `tag`.
//   public init<V>(
//    destination: Destination,
//    tag: V, selection: Binding<V?>,
//    @ViewBuilder label: () -> Label
//   ) where V : Hashable

  public var body: Never {
    neverBody("NavigationLink")
  }
}

extension NavigationLink where Label == Text {
  /// Creates an instance that presents `destination`, with a `Text` label
  /// generated from a title string.
  public init<S>(_ title: S, destination: Destination) where S: StringProtocol {
    self.destination = destination
    label = Text(title)
  }

  /// Creates an instance that presents `destination` when active, with a
  /// `Text` label generated from a title string.
//   public init<S>(
//    _ title: S, destination: Destination,
//    isActive: Binding<Bool>
//   ) where S : StringProtocol

  /// Creates an instance that presents `destination` when `selection` is set
  /// to `tag`, with a `Text` label generated from a title string.
//  public init<S, V>(
//    _ title: S, destination: Destination,
//    tag: V, selection: Binding<V?>
//  ) where S : StringProtocol, V : Hashable
}

public func navigationViewContent<Content>(
  _ navigationView: NavigationView<Content>
) -> Content {
  navigationView.content
}

public func navigationLinkContent<Label, Destination>(
  _ navigationLink: NavigationLink<Label, Destination>
) -> Label {
  navigationLink.label
}

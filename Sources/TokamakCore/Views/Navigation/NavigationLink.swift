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

final class NavigationLinkDestination {
  let view: AnyView
  init<V: View>(_ destination: V) {
    view = AnyView(destination)
  }
}

public struct NavigationLink<Label, Destination>: _PrimitiveView where Label: View,
  Destination: View
{
  @State
  var destination: NavigationLinkDestination

  let label: Label

  @EnvironmentObject
  var navigationContext: NavigationContext

  @Environment(\._navigationLinkStyle)
  var style

  public init(destination: Destination, @ViewBuilder label: () -> Label) {
    _destination = State(wrappedValue: NavigationLinkDestination(destination))
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
}

public extension NavigationLink where Label == Text {
  /// Creates an instance that presents `destination`, with a `Text` label
  /// generated from a title string.
  init<S>(_ title: S, destination: Destination) where S: StringProtocol {
    self.init(destination: destination) { Text(title) }
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

/// This is a helper type that works around absence of "package private" access control in Swift
public struct _NavigationLinkProxy<Label, Destination> where Label: View, Destination: View {
  public let subject: NavigationLink<Label, Destination>

  public init(_ subject: NavigationLink<Label, Destination>) {
    self.subject = subject
  }

  public var label: some View {
    subject.style.makeBody(configuration: .init(
      body: AnyView(subject.label),
      isSelected: isSelected
    ))
    // subject.label
  }

  public var context: NavigationContext { subject.navigationContext }

  public var style: _AnyNavigationLinkStyle { subject.style }
  public var isSelected: Bool {
    subject.destination === subject.navigationContext.destination
  }

  public func activate() {
    if !isSelected {
      subject.navigationContext.destination = subject.destination
    }
  }
}

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

public protocol ViewModifier {
  typealias Content = _ViewModifier_Content<Self>
  associatedtype Body: View
  func body(content: Content) -> Self.Body

  func size<T, C: View>(for proposedSize: ProposedSize, hostView: MountedHostView<T>, content: C)
    -> CGSize
  func layout<T, C: View>(size: CGSize, hostView: MountedHostView<T>, content: C)
}

public extension ViewModifier {
  func size<T, C: View>(for proposedSize: ProposedSize, hostView: MountedHostView<T>,
                        content: C) -> CGSize
  {
    let children = hostView.getChildren()
    let childSize = content._size(for: proposedSize, hostView: children[0])
    print("DEFAULT VIEWMODIFIER SIZE", childSize)
    return childSize
//    return CGSize(width: childSize.width + 50, height: childSize.height + 50)
  }

  func layout<T, C: View>(size: CGSize, hostView: MountedHostView<T>, content: C) {
    let children = hostView.getChildren()
    print("DEFAULT VIEWMODIFIER LAYOUT")
    content._layout(size: size, hostView: children[0])
  }
}

public struct _ViewModifier_Content<Modifier>: View where Modifier: ViewModifier {
  public let modifier: Modifier
  public let view: AnyView

  public init(modifier: Modifier, view: AnyView) {
    self.modifier = modifier
    self.view = view
  }

  public var body: AnyView {
    view
  }
}

public extension View {
  func modifier<Modifier>(_ modifier: Modifier) -> ModifiedContent<Self, Modifier> {
    .init(content: self, modifier: modifier)
  }
}

public extension ViewModifier where Body == Never {
  func body(content: Content) -> Body {
    fatalError(
      "\(Self.self) is a primitive `ViewModifier`, you're not supposed to run `body(content:)`"
    )
  }
}

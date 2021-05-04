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

public struct _PaddingLayout: ViewModifier {
  public var edges: Edge.Set
  public var insets: EdgeInsets?

  public init(edges: Edge.Set = .all, insets: EdgeInsets?) {
    self.edges = edges
    self.insets = insets
  }

  public func body(content: Content) -> some View {
    content
  }
}

public extension _PaddingLayout {
  func size<T, C: View>(for proposedSize: ProposedSize, hostView: MountedHostView<T>,
                        content: C) -> CGSize
  {
    let children = hostView.getChildren()
    let childSize = content._size(for: proposedSize, hostView: children[0])
    return CGSize(
      width: childSize.width + (insets?.leading ?? 0) + (insets?.trailing ?? 0),
      height: childSize.height + (insets?.top ?? 0) + (insets?.bottom ?? 0)
    )
  }

  func layout<T, C: View>(size: CGSize, hostView: MountedHostView<T>, content: C) {
    guard let context = hostView.target?.context else { return }
    print("FRAMELAYOUT LAYOUT")
    let children = hostView.getChildren()

    context.push()
    var prop = ProposedSize(size)
    if var width = prop.width {
      width -= (insets?.leading ?? 0) + (insets?.trailing ?? 0)
      prop.width = width
    }
    if var height = prop.height {
      height -= (insets?.top ?? 0) + (insets?.bottom ?? 0)
      prop.height = height
    }
    let childSize = content._size(for: prop, hostView: children[0])

    context.align(childSize, in: size, alignment: .center)

    content._layout(size: childSize, hostView: children[0])
    context.pop()
  }
}

public extension View {
  func padding(_ insets: EdgeInsets) -> some View {
    modifier(_PaddingLayout(insets: insets))
  }

  func padding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
    let insets = length.map { EdgeInsets(_all: $0) }
    return modifier(_PaddingLayout(edges: edges, insets: insets))
  }

  func padding(_ length: CGFloat) -> some View {
    padding(.all, length)
  }
}

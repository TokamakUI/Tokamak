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

/// A view that overlays its children, aligning them in both axes.
///
///     ZStack {
///       Text("Bottom")
///       Text("Top")
///     }
///
public struct ZStack<Content>: PrimitiveView where Content: View {
  public let alignment: Alignment
  public let spacing: CGFloat?
  public let content: Content

  public init(
    alignment: Alignment = .center,
    spacing: CGFloat? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.alignment = alignment
    self.spacing = spacing
    self.content = content()
  }
}

extension ZStack: ParentView {
  @_spi(TokamakCore)
  public var children: [AnyView] {
    (content as? GroupView)?.children ?? [AnyView(content)]
  }
}

extension ZStack: BuiltinView {
  public func layout<T>(size: CGSize, hostView: MountedHostView<T>) {
    guard let context = hostView.target?.context else { return }
    let children = hostView.getChildren()
    for idx in children.indices {
      let child = children[idx]
      guard let childView = mapAnyView(
        child.view,
        transform: { (view: View) in view }
      ) else {
        continue
      }
      // TODO: Reuse size measured previously
      let childSize = childView._size(for: ProposedSize(size), hostView: child)
      context.push()
      context.align(childSize, in: size, alignment: alignment)
      childView._layout(size: childSize, hostView: child)
      context.pop()
    }
  }

  public func size<T>(for proposedSize: ProposedSize, hostView: MountedHostView<T>) -> CGSize {
    let children = hostView.getChildren()

    var sizes: [CGSize] = []
    for idx in children.indices {
      let child = children[idx]
      guard let childView = mapAnyView(
        child.view,
        transform: { (view: View) in view }
      ) else {
        continue
      }
      sizes.append(childView._size(for: proposedSize, hostView: child))
    }
    let width = sizes.map(\.width).reduce(0, max)
    let height = sizes.map(\.height).reduce(0, max)
    return CGSize(width: width, height: height)
  }
}

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

/// An alignment in both axes.
//public struct Alignment: Equatable {
//  public var horizontal: HorizontalAlignment
//  public var vertical: VerticalAlignment
//
//  public init(
//    horizontal: HorizontalAlignment,
//    vertical: VerticalAlignment
//  ) {
//    self.horizontal = horizontal
//    self.vertical = vertical
//  }
//
//  public static let topLeading = Self(horizontal: .leading, vertical: .top)
//  public static let top = Self(horizontal: .center, vertical: .top)
//  public static let topTrailing = Self(horizontal: .trailing, vertical: .top)
//  public static let leading = Self(horizontal: .leading, vertical: .center)
//  public static let center = Self(horizontal: .center, vertical: .center)
//  public static let trailing = Self(horizontal: .trailing, vertical: .center)
//  public static let bottomLeading = Self(horizontal: .leading, vertical: .bottom)
//  public static let bottom = Self(horizontal: .center, vertical: .bottom)
//  public static let bottomTrailing = Self(horizontal: .trailing, vertical: .bottom)
//}

/// A view that overlays its children, aligning them in both axes.
///
///     ZStack {
///       Text("Bottom")
///       Text("Top")
///     }
///
public struct ZStack<Content>: View where Content: View {
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

  public var body: Never {
    neverBody("ZStack")
  }
}

extension ZStack: ParentView {
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

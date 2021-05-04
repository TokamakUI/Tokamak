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
//  Created by Carson Katri on 6/29/20.
//

public struct _Background<Content, Background>: View
  where Background: View, Content: View
{
  public var environment: EnvironmentValues!
  public var content: Content
  public var background: Background
  public var alignment: Alignment

  public init(content: Content, background: Background, alignment: Alignment = .center) {
    self.background = background
    self.content = content
    self.alignment = alignment
  }

  public var body: some View {
    neverBody("_Background")
  }
}

extension _Background: BuiltinView where Content: View, Background: View {
  public func layout<T>(size: CGSize, hostView: MountedHostView<T>) {
    print("LAYOUT _BACKGROUND CONTENT", size, content)
    let children = hostView.getChildren()

    let childSize = background._size(for: ProposedSize(size), hostView: children[0])
    print("CHILDSIZE", childSize)
    background._layout(size: childSize, hostView: children[0])

    content._layout(size: size, hostView: children[1])
  }

  public func size<T>(for proposedSize: ProposedSize, hostView: MountedHostView<T>) -> CGSize {
    print("SIZING _BACKGROUND CONTENT")
    let children = hostView.getChildren()
    return content._size(for: proposedSize, hostView: children[1])
  }
}

extension _Background: ParentView {
  public var children: [AnyView] {
    [AnyView(background), AnyView(content)]
  }
}

public struct _BackgroundModifier<Background>: ViewModifier, EnvironmentReader
  where Background: View
{
  public var environment: EnvironmentValues!
  public var background: Background
  public var alignment: Alignment

  public init(background: Background, alignment: Alignment = .center) {
    self.background = background
    self.alignment = alignment
  }

  public func body(content: Content) -> some View {
    _Background(content: content, background: background, alignment: alignment)
  }

  mutating func setContent(from values: EnvironmentValues) {
    environment = values
  }
}

// public extension _BackgroundModifier {
//   func size<T, C: View>(
//     for proposedSize: ProposedSize,
//     hostView: MountedHostView<T>,
//     content: C
//   ) -> CGSize {
//     print("BACKGROUND SIZE")
//     let children = hostView.getChildren()
//     print("CHILDREN", children.map(\.view))
//     let childSize = content._size(for: proposedSize, hostView: children[1])
//     return childSize
//   }

//   func layout<T, C: View>(size: CGSize, hostView: MountedHostView<T>, content: C) {
//     guard let context = hostView.target?.context else { return }
//     print("BACKGROUND LAYOUT")
//     let children = hostView.getChildren()

//     context.push()

//     background._layout(size: size, hostView: children[0])
//     content._layout(size: size, hostView: children[1])
//     context.pop()
//   }
// }

extension _BackgroundModifier: Equatable where Background: Equatable {
  public static func == (
    lhs: _BackgroundModifier<Background>,
    rhs: _BackgroundModifier<Background>
  ) -> Bool {
    lhs.background == rhs.background
  }
}

public extension View {
  func background<Background>(
    _ background: Background,
    alignment: Alignment = .center
  ) -> some View where Background: View {
    _Background(content: self, background: background, alignment: alignment)

//    modifier(_BackgroundModifier(background: background, alignment: alignment))
  }
}

public struct _Overlay<Content, Overlay>: View
  where Overlay: View, Content: View
{
  public var environment: EnvironmentValues!
  public var content: Content
  public var overlay: Overlay
  public var alignment: Alignment

  public init(content: Content, overlay: Overlay, alignment: Alignment = .center) {
    self.overlay = overlay
    self.content = content
    self.alignment = alignment
  }

  public var body: some View {
    neverBody("_Overlay")
//    // FIXME: Clip to content shape.
//    ZStack(alignment: alignment) {
//      content
//      overlay
//    }
  }
}

extension _Overlay: BuiltinView where Content: View, Overlay: View {
  public func layout<T>(size: CGSize, hostView: MountedHostView<T>) {
    print("LAYOUT _OVERLAY CONTENT", size, content)
    let children = hostView.getChildren()
    content._layout(size: size, hostView: children[0])

    let childSize = overlay._size(for: ProposedSize(size), hostView: children[1])
    print("CHILDSIZE", childSize)
    overlay._layout(size: childSize, hostView: children[1])
  }

  public func size<T>(for proposedSize: ProposedSize, hostView: MountedHostView<T>) -> CGSize {
    print("SIZING _OVERLAY CONTENT")
    let children = hostView.getChildren()
    return content._size(for: proposedSize, hostView: children[0])
  }
}

extension _Overlay: ParentView {
  public var children: [AnyView] {
    [AnyView(content), AnyView(overlay)]
  }
}

public struct _OverlayModifier<Overlay>: ViewModifier, EnvironmentReader
  where Overlay: View
{
  public var environment: EnvironmentValues!
  public var overlay: Overlay
  public var alignment: Alignment

  public init(overlay: Overlay, alignment: Alignment = .center) {
    self.overlay = overlay
    self.alignment = alignment
  }

  public func body(content: Content) -> some View {
    _Overlay(content: content, overlay: overlay, alignment: alignment)
  }

  mutating func setContent(from values: EnvironmentValues) {
    environment = values
  }
}

extension _OverlayModifier: Equatable where Overlay: Equatable {
  public static func == (lhs: _OverlayModifier<Overlay>, rhs: _OverlayModifier<Overlay>) -> Bool {
    lhs.overlay == rhs.overlay
  }
}

public extension View {
  func overlay<Overlay>(_ overlay: Overlay, alignment: Alignment = .center) -> some View
    where Overlay: View
  {
    _Overlay(content: self, overlay: overlay, alignment: alignment)
//    modifier(_OverlayModifier(overlay: overlay, alignment: alignment))
  }

  func border<S>(_ content: S, width: CGFloat = 1) -> some View where S: ShapeStyle {
    overlay(Rectangle().strokeBorder(content, lineWidth: width))
  }
}

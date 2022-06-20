// Copyright 2020-2021 Tokamak contributors
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

import Foundation

/// Override this View's body to provide a layout that fits the background to the content.
public struct _BackgroundLayout<Content, Background>: _PrimitiveView
  where Content: View, Background: View
{
  public let content: Content
  public let background: Background
  public let alignment: Alignment

  @_spi(TokamakCore)
  public init(content: Content, background: Background, alignment: Alignment) {
    self.content = content
    self.background = background
    self.alignment = alignment
  }

  public func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    visitor.visit(background)
    visitor.visit(content)
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
    _BackgroundLayout(
      content: content,
      background: background,
      alignment: alignment
    )
  }

  mutating func setContent(from values: EnvironmentValues) {
    environment = values
  }
}

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
    modifier(_BackgroundModifier(background: background, alignment: alignment))
  }

  @inlinable
  func background<V>(
    alignment: Alignment = .center,
    @ViewBuilder content: () -> V
  ) -> some View where V: View {
    background(content(), alignment: alignment)
  }
}

@frozen
public struct _BackgroundShapeModifier<Style, Bounds>: ViewModifier, EnvironmentReader
  where Style: ShapeStyle, Bounds: Shape
{
  public var environment: EnvironmentValues!

  public var style: Style
  public var shape: Bounds
  public var fillStyle: FillStyle

  @inlinable
  public init(style: Style, shape: Bounds, fillStyle: FillStyle) {
    self.style = style
    self.shape = shape
    self.fillStyle = fillStyle
  }

  public func body(content: Content) -> some View {
    content
      .background(shape.fill(style, style: fillStyle))
  }

  public mutating func setContent(from values: EnvironmentValues) {
    environment = values
  }
}

public extension View {
  @inlinable
  func background<S, T>(
    _ style: S,
    in shape: T,
    fillStyle: FillStyle = FillStyle()
  ) -> some View where S: ShapeStyle, T: Shape {
    modifier(_BackgroundShapeModifier(style: style, shape: shape, fillStyle: fillStyle))
  }

  @inlinable
  func background<S>(
    in shape: S,
    fillStyle: FillStyle = FillStyle()
  ) -> some View where S: Shape {
    background(BackgroundStyle(), in: shape, fillStyle: fillStyle)
  }
}

/// Override this View's body to provide a layout that fits the background to the content.
public struct _OverlayLayout<Content, Overlay>: _PrimitiveView
  where Content: View, Overlay: View
{
  public let content: Content
  public let overlay: Overlay
  public let alignment: Alignment

  public func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    visitor.visit(content)
    visitor.visit(overlay)
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
    _OverlayLayout(
      content: content,
      overlay: overlay,
      alignment: alignment
    )
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
    modifier(_OverlayModifier(overlay: overlay, alignment: alignment))
  }

  @inlinable
  func overlay<V>(
    alignment: Alignment = .center,
    @ViewBuilder content: () -> V
  ) -> some View where V: View {
    modifier(_OverlayModifier(overlay: content(), alignment: alignment))
  }

  @inlinable
  func overlay<S>(
    _ style: S
  ) -> some View where S: ShapeStyle {
    overlay(Rectangle().fill(style))
  }

  func border<S>(_ content: S, width: CGFloat = 1) -> some View where S: ShapeStyle {
    overlay(Rectangle().strokeBorder(content, lineWidth: width))
  }
}

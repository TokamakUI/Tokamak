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

import Foundation
@_spi(TokamakCore)
import TokamakCore

extension _BackgroundStyleModifier: DOMViewModifier {
  public var isOrderDependent: Bool { true }
  private func attributes(
    for material: _MaterialStyle,
    color: AnyColorBox.ResolvedValue
  ) -> [HTMLAttribute: String] {
    let blur: (opacity: Double, radius: Double)
    switch material {
    case .ultraThin:
      blur = (0.2, 20)
    case .thin:
      blur = (0.4, 25)
    case .regular:
      blur = (0.5, 30)
    case .thick:
      blur = (0.6, 40)
    case .ultraThick:
      blur = (0.6, 50)
    }
    return [
      "style":
        """
        background-color: rgba(\(color.red * 255), \(color.green * 255), \(color
          .blue * 255), \(blur
          .opacity));
        -webkit-backdrop-filter: blur(\(blur.radius)px);
        backdrop-filter: blur(\(blur.radius)px);
        """,
    ]
  }

  public var attributes: [HTMLAttribute: String] {
    if let resolved = style.resolve(
      for: .resolveStyle(levels: 0..<1),
      in: environment,
      role: .fill
    ) {
      if case let .foregroundMaterial(color, material) = resolved {
        return attributes(for: material, color: color)
      } else if let color = resolved.color(at: 0) {
        return [
          "style": "background-color: \(color.cssValue(environment));",
        ]
      }
    }
    return [:]
  }
}

@_spi(TokamakStaticHTML)
extension _BackgroundStyleModifier: HTMLConvertible,
  HTMLModifierConvertible
{
  public var tag: String { "div" }
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    let resolved = style.resolve(
      for: .resolveStyle(levels: 0..<1),
      in: environment,
      role: .fill
    )
    if case let .foregroundMaterial(color, material) = resolved {
      return attributes(for: material, color: color)
    } else {
      return [:]
    }
  }

  public func primitiveVisitor<V, Content>(
    content: Content,
    useDynamicLayout: Bool
  ) -> ((V) -> ())? where V: ViewVisitor, Content: View {
    let resolved = style.resolve(
      for: .resolveStyle(levels: 0..<1),
      in: environment,
      role: .fill
    )
    if case .foregroundMaterial = resolved {
      return nil
    } else {
      return {
        $0
          .visit(
            _BackgroundStyleLayout(
              style: style,
              backgroundLayout: _BackgroundLayout(
                content: content,
                background: _ShapeView(shape: Rectangle(), style: style),
                alignment: .center
              )
            )
          )
      }
    }
  }
}

struct _BackgroundStyleLayout<
  Content: View,
  Style: ShapeStyle
>: _PrimitiveView, HTMLConvertible, Layout {
  let style: Style
  let backgroundLayout: _BackgroundLayout<Content, _ShapeView<Rectangle, Style>>

  @Environment(\.self)
  var environment
  @State
  private var fillsScene = false

  var tag: String { "div" }
  func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    [:]
  }

  func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    visitor.visit(backgroundLayout.background)
    visitor.visit(backgroundLayout.content)
    // If the background reaches the top of the scene, apply a "theme-color".
    // This matches SwiftUI's behavior where a `_BackgroundStyleModifier` that reaches the top
    // will extend into the safe area.
    if fillsScene {
      var shape = _ShapeStyle_Shape(
        for: .resolveStyle(levels: 0..<1),
        in: environment,
        role: .fill
      )
      style._apply(to: &shape)
      guard let style = shape.result.resolvedStyle(on: shape, in: environment),
            let color = style.color(at: 0)
      else { return }
      visitor.visit(HTMLMeta(
        name: "theme-color",
        content: color.cssValue(environment)
      ))
    }
  }

  typealias Cache = _BackgroundLayout<Content, _ShapeView<Rectangle, Style>>.Cache

  func makeCache(subviews: Subviews) -> Cache {
    backgroundLayout.makeCache(subviews: subviews)
  }

  func spacing(subviews: LayoutSubviews, cache: inout Cache) -> ViewSpacing {
    backgroundLayout.spacing(subviews: subviews, cache: &cache)
  }

  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Cache
  ) -> CGSize {
    backgroundLayout.sizeThatFits(proposal: proposal, subviews: subviews, cache: &cache)
  }

  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Cache
  ) {
    // If the minY == 0, we are touching the top of the scene.
    let fillsScene = subviews.globalOrigin.y == 0
    if fillsScene != self.fillsScene {
      self.fillsScene = fillsScene
    }
    return backgroundLayout.placeSubviews(
      in: bounds,
      proposal: proposal,
      subviews: subviews,
      cache: &cache
    )
  }
}

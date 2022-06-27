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

import Foundation
import TokamakCore

private extension DOMViewModifier {
  func unwrapToStyle<T>(
    _ key: KeyPath<Self, T?>,
    property: String? = nil,
    defaultValue: String = ""
  ) -> String {
    if let val = self[keyPath: key] {
      if let property = property {
        return "\(property): \(val)px;"
      } else {
        return "\(val)px;"
      }
    } else {
      return defaultValue
    }
  }
}

private extension VerticalAlignment {
  var flexAlignment: String {
    switch self {
    case .top: return "flex-start"
    case .center: return "center"
    case .bottom: return "flex-end"
    default: return "center"
    }
  }
}

private extension HorizontalAlignment {
  var flexAlignment: String {
    switch self {
    case .leading: return "flex-start"
    case .center: return "center"
    case .trailing: return "flex-end"
    default: return "center"
    }
  }
}

extension _FrameLayout: DOMViewModifier {
  public var isOrderDependent: Bool { true }
  public var attributes: [HTMLAttribute: String] {
    ["style": """
    \(unwrapToStyle(\.width, property: "width"))
    \(unwrapToStyle(\.height, property: "height"))
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    flex-grow: 0;
    flex-shrink: 0;
    display: flex;
    align-items: \(alignment.vertical.flexAlignment);
    justify-content: \(alignment.horizontal.flexAlignment);
    """]
  }
}

@_spi(TokamakStaticHTML)
extension _FrameLayout: HTMLConvertible {
  public var tag: String { "div" }
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    guard !useDynamicLayout else { return [:] }
    return attributes
  }
}

extension _FlexFrameLayout: DOMViewModifier {
  public var isOrderDependent: Bool { true }
  public var attributes: [HTMLAttribute: String] {
    ["style": """
    \(unwrapToStyle(\.minWidth, property: "min-width"))
    width: \(unwrapToStyle(\.idealWidth, defaultValue: fillWidth ? "100%" : "auto"));
    \(unwrapToStyle(\.maxWidth, property: "max-width"))
    \(unwrapToStyle(\.minHeight, property: "min-height"))
    height: \(unwrapToStyle(\.idealHeight, defaultValue: fillHeight ? "100%" : "auto"));
    \(unwrapToStyle(\.maxHeight, property: "max-height"))
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    flex-grow: 0;
    flex-shrink: 0;
    display: flex;
    align-items: \(alignment.vertical.flexAlignment);
    justify-content: \(alignment.horizontal.flexAlignment);
    """]
  }
}

@_spi(TokamakStaticHTML)
extension _FlexFrameLayout: HTMLConvertible {
  public var tag: String { "div" }
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    guard !useDynamicLayout else { return [:] }
    return attributes
  }
}

private extension Edge {
  var cssValue: String {
    switch self {
    case .top: return "top"
    case .trailing: return "right"
    case .bottom: return "bottom"
    case .leading: return "left"
    }
  }
}

private extension EdgeInsets {
  func inset(for edge: Edge) -> CGFloat {
    switch edge {
    case .top: return top
    case .trailing: return trailing
    case .bottom: return bottom
    case .leading: return leading
    }
  }
}

extension _PaddingLayout: DOMViewModifier {
  public var isOrderDependent: Bool { true }
  public var attributes: [HTMLAttribute: String] {
    var padding = [(String, CGFloat)]()
    let insets = insets ?? .init(_all: 10)
    for edge in Edge.allCases {
      if edges.contains(.init(edge)) {
        padding.append((edge.cssValue, insets.inset(for: edge)))
      }
    }
    return ["style": padding
      .map { "padding-\($0.0): \($0.1)px;" }
      .joined(separator: " ")]
  }
}

@_spi(TokamakStaticHTML)
extension _PaddingLayout: HTMLConvertible {
  public var tag: String { "div" }
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    guard !useDynamicLayout else { return [:] }
    return attributes
  }
}

extension _ShadowEffect._Resolved: DOMViewModifier {
  public var attributes: [HTMLAttribute: String] {
    [
      "style": """
      box-shadow: \(offset.width)px \(offset.height)px \(radius * 2)px 0px \(color.cssValue);
      """,
    ]
  }

  public var isOrderDependent: Bool { true }
}

extension _AspectRatioLayout: DOMViewModifier {
  public var isOrderDependent: Bool { true }
  public var attributes: [HTMLAttribute: String] {
    [
      "style": """
      aspect-ratio: \(aspectRatio ?? 1)/1;
      margin: 0 auto;
      \(contentMode == ((aspectRatio ?? 1) > 1 ? .fill : .fit) ? "height: 100%" : "width: 100%");
      """,
      "class": "_tokamak-aspect-ratio-\(contentMode == .fill ? "fill" : "fit")",
    ]
  }
}

extension _BackgroundLayout: _HTMLPrimitive {
  public var renderedBody: AnyView {
    AnyView(
      HTML(
        "div",
        ["style": "display: inline-grid; grid-template-columns: auto auto;"]
      ) {
        HTML(
          "div",
          ["style": """
          display: flex;
          justify-content: \(alignment.horizontal.flexAlignment);
          align-items: \(alignment.vertical.flexAlignment);
          grid-area: a;

          width: 0; min-width: 100%;
          height: 0; min-height: 100%;
          overflow: hidden;
          """]
        ) {
          background
        }
        HTML("div", ["style": "grid-area: a;"]) {
          content
        }
      }
    )
  }
}

@_spi(TokamakStaticHTML)
extension _BackgroundLayout: HTMLConvertible {
  public var tag: String {
    "div"
  }

  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    guard !useDynamicLayout else { return [:] }
    return ["style": "display: inline-grid; grid-template-columns: auto auto;"]
  }

  public func primitiveVisitor<V>(useDynamicLayout: Bool) -> ((V) -> ())? where V: ViewVisitor {
    guard !useDynamicLayout else { return nil }
    return {
      $0.visit(HTML(
        "div",
        ["style": """
        display: flex;
        justify-content: \(alignment.horizontal.flexAlignment);
        align-items: \(alignment.vertical.flexAlignment);
        grid-area: a;

        width: 0; min-width: 100%;
        height: 0; min-height: 100%;
        overflow: hidden;
        """]
      ) {
        background
      })
      $0.visit(HTML("div", ["style": "grid-area: a;"]) {
        content
      })
    }
  }
}

extension _OverlayLayout: _HTMLPrimitive {
  public var renderedBody: AnyView {
    AnyView(
      HTML(
        "div",
        ["style": "display: inline-grid; grid-template-columns: auto auto;"]
      ) {
        HTML("div", ["style": "grid-area: a;"]) {
          content
        }
        HTML(
          "div",
          ["style": """
          display: flex;
          justify-content: \(alignment.horizontal.flexAlignment);
          align-items: \(alignment.vertical.flexAlignment);
          grid-area: a;

          width: 0; min-width: 100%;
          height: 0; min-height: 100%;
          overflow: hidden;
          """]
        ) {
          overlay
        }
      }
    )
  }
}

@_spi(TokamakStaticHTML)
extension _OverlayLayout: HTMLConvertible {
  public var tag: String { "div" }
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    guard !useDynamicLayout else { return [:] }
    return ["style": "display: inline-grid; grid-template-columns: auto auto;"]
  }

  public func primitiveVisitor<V>(useDynamicLayout: Bool) -> ((V) -> ())? where V: ViewVisitor {
    guard !useDynamicLayout else { return nil }
    return {
      $0.visit(HTML("div", ["style": "grid-area: a;"]) {
        content
      })
      $0.visit(
        HTML(
          "div",
          ["style": """
          display: flex;
          justify-content: \(alignment.horizontal.flexAlignment);
          align-items: \(alignment.vertical.flexAlignment);
          grid-area: a;

          width: 0; min-width: 100%;
          height: 0; min-height: 100%;
          overflow: hidden;
          """]
        ) {
          overlay
        }
      )
    }
  }
}

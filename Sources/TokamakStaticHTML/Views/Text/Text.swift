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

extension Font.Design: CustomStringConvertible {
  /// Some default font stacks for the various designs
  public var description: String {
    switch self {
    case .default:
      return #"""
      system,
      -apple-system,
      '.SFNSText-Regular',
      'San Francisco',
      'Roboto',
      'Segoe UI',
      'Helvetica Neue',
      'Lucida Grande',
      sans-serif
      """#
    case .monospaced:
      return #"""
      Consolas,
      'Andale Mono WT',
      'Andale Mono',
      'Lucida Console',
      'Lucida Sans Typewriter',
      'DejaVu Sans Mono',
      'Bitstream Vera Sans Mono',
      'Liberation Mono',
      'Nimbus Mono L',
      Monaco,
      'Courier New',
      Courier,
      monospace
      """#
    case .rounded: // Not supported due to browsers not having a rounded font builtin
      return Self.default.description
    case .serif:
      return #"""
      Cambria,
      'Hoefler Text',
      Utopia,
      'Liberation Serif',
      'Nimbus Roman No9 L Regular',
      Times,
      'Times New Roman',
      serif
      """#
    }
  }
}

extension Font.Leading: CustomStringConvertible {
  public var description: String {
    switch self {
    case .standard:
      return "normal"
    case .loose:
      return "1.5"
    case .tight:
      return "0.5"
    }
  }
}

public extension Font {
  func styles(in environment: EnvironmentValues) -> [String: String] {
    let proxy = _FontProxy(self).resolve(in: environment)
    return [
      "font-family": proxy._name == _FontNames.system.rawValue ? proxy._design.description : proxy
        ._name,
      "font-weight": "\(proxy._bold ? Font.Weight.bold.value : proxy._weight.value)",
      "font-style": proxy._italic ? "italic" : "normal",
      "font-size": "\(proxy._size)",
      "line-height": proxy._leading.description,
      "font-variant": proxy._smallCaps ? "small-caps" : "normal",
    ]
  }
}

extension TextAlignment: CustomStringConvertible {
  public var description: String {
    switch self {
    case .leading: return "left"
    case .center: return "center"
    case .trailing: return "right"
    }
  }
}

private struct TextSpan: AnyHTML {
  let content: String
  let attributes: [HTMLAttribute: String]

  public func innerHTML(shouldSortAttributes: Bool) -> String? { content }
  var tag: String { "span" }
}

extension Text: AnyHTML {
  public func innerHTML(shouldSortAttributes: Bool) -> String? {
    let proxy = _TextProxy(self)
    let innerHTML: String
    switch proxy.storage {
    case let .verbatim(text):
      innerHTML = text
    case let .segmentedText(segments):
      innerHTML = segments
        .map {
          TextSpan(
            content: $0.0.rawText,
            attributes: Self.attributes(
              from: $0.1,
              environment: proxy.environment
            )
          )
          .outerHTML(shouldSortAttributes: shouldSortAttributes, children: [])
        }
        .reduce("", +)
    }
    return innerHTML.replacingOccurrences(of: "\n", with: "<br />")
  }

  public var tag: String { "span" }
  public var attributes: [HTMLAttribute: String] {
    let proxy = _TextProxy(self)
    return Self.attributes(
      from: proxy.modifiers,
      environment: proxy.environment
    )
  }
}

extension Text {
  static func attributes(
    from modifiers: [_Modifier],
    environment: EnvironmentValues
  ) -> [HTMLAttribute: String] {
    let isRedacted = environment.redactionReasons.contains(.placeholder)

    var font: Font?
    var color: Color?
    var italic: Bool = false
    var weight: Font.Weight?
    var kerning: String = "normal"
    var baseline: CGFloat?
    var strikethrough: (Bool, Color?)?
    var underline: (Bool, Color?)?
    for modifier in modifiers {
      switch modifier {
      case let .color(_color):
        color = _color
      case let .font(_font):
        font = _font
      case .italic:
        italic = true
      case let .weight(_weight):
        weight = _weight
      case let .kerning(_kerning), let .tracking(_kerning):
        kerning = "\(_kerning)em"
      case let .baseline(_baseline):
        baseline = _baseline
      case .rounded: break
      case let .strikethrough(active, color):
        strikethrough = (active, color)
      case let .underline(active, color):
        underline = (active, color)
      }
    }

    let hasStrikethrough = strikethrough?.0 ?? false
    let hasUnderline = underline?.0 ?? false
    let textDecoration = !hasStrikethrough && !hasUnderline ? "none" :
      "\(hasStrikethrough ? "line-through" : "") \(hasUnderline ? "underline" : "")"
    let decorationColor = strikethrough?.1?.cssValue(environment)
      ?? underline?.1?.cssValue(environment)
      ?? "inherit"
    let resolvedFont = font == nil ? nil : _FontProxy(font!).resolve(in: environment)

    return [
      "style": """
      \(font?.styles(in: environment).filter { weight != nil ? $0.key != "font-weight" : true }
        .inlineStyles ?? "")
      \(font == nil ? "font-family: \(Font.Design.default.description);" : "")
      color: \((color ?? .primary).cssValue(environment));
      font-style: \(italic ? "italic" : "normal");
      font-weight: \(weight?.value ?? resolvedFont?._weight.value ?? 400);
      letter-spacing: \(kerning);
      vertical-align: \(baseline == nil ? "baseline" : "\(baseline!)em");
      text-decoration: \(textDecoration);
      text-decoration-color: \(decorationColor);
      text-align: \(environment.multilineTextAlignment.description);
      """,
      "class": isRedacted ? "_tokamak-text-redacted" : "",
    ]
  }
}

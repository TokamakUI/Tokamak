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

extension Font: StylesConvertible {
  public var styles: [String: String] {
    [
      "font-family": _name == _FontNames.system.rawValue ? _design.description : _name,
      "font-weight": "\(_bold ? Font.Weight.bold.value : _weight.value)",
      "font-style": _italic ? "italic" : "normal",
      "font-size": "\(_size)pt",
      "line-height": _leading.description,
      "font-variant": _smallCaps ? "small-caps" : "normal",
    ]
  }
}

private struct TextSpan: AnyHTML {
  let content: String
  let attributes: [String: String]

  var innerHTML: String? { content }
  var tag: String { "span" }
}

extension Text: AnyHTML {
  public var innerHTML: String? {
    let proxy = _TextProxy(self)
    switch proxy.storage {
    case let .verbatim(text):
      return text
    case let .segmentedText(segments):
      return segments
        .map {
          TextSpan(
            content: $0.0.rawText,
            attributes: Self.attributes(
              from: $0.1,
              environment: proxy.environment
            )
          )
          .outerHTML
        }
        .reduce("", +)
    }
  }

  public var tag: String { "span" }
  public var attributes: [String: String] {
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
  ) -> [String: String] {
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
    let textDecoration = !hasStrikethrough && !hasUnderline ?
      "none" :
      "\(hasStrikethrough ? "line-through" : "") \(hasUnderline ? "underline" : "")"
    let decorationColor = strikethrough?.1?.cssValue(environment)
      ?? underline?.1?.cssValue(environment)
      ?? "inherit"

    return [
      "style": """
      \(font?.styles.filter { weight != nil ? $0.key != "font-weight" : true }.inlineStyles ?? "")
      \(font == nil ? "font-family: \(Font.Design.default.description);" : "")
      color: \((color ?? .primary).cssValue(environment));
      font-style: \(italic ? "italic" : "normal");
      font-weight: \(weight?.value ?? font?._weight.value ?? 400);
      letter-spacing: \(kerning);
      vertical-align: \(baseline == nil ? "baseline" : "\(baseline!)em");
      text-decoration: \(textDecoration);
      text-decoration-color: \(decorationColor)
      """,
      "class": isRedacted ? "_tokamak-text-redacted" : "",
    ]
  }
}

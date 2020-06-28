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

import JavaScriptKit
import TokamakCore

public typealias Text = TokamakCore.Text

extension Font.Design: CustomStringConvertible {
  /// Some default font stacks for the various designs
  public var description: String {
    switch self {
    case .default:
      return "system, -apple-system, \".SFNSText-Regular\", \"San Francisco\", \"Roboto\", \"Segoe UI\", \"Helvetica Neue\", \"Lucida Grande\", sans-serif"
    case .monospaced:
      return "Consolas, \"Andale Mono WT\", \"Andale Mono\", \"Lucida Console\", \"Lucida Sans Typewriter\", \"DejaVu Sans Mono\", \"Bitstream Vera Sans Mono\", \"Liberation Mono\", \"Nimbus Mono L\", Monaco, \"Courier New\", Courier, monospace"
    case .rounded: // Not supported due to browsers not having a rounded font builtin
      return Self.default.description
    case .serif:
      return "Cambria, \"Hoefler Text\", Utopia, \"Liberation Serif\", \"Nimbus Roman No9 L Regular\", Times, \"Times New Roman\", serif"
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
  var styles: [String: String] {
    [
      "font-family": _name == _FontNames.system.rawValue ? _design.description : _name,
      "font-weight": "\(_bold ? 700 : _weight.value)",
      "font-style": _italic ? "italic" : "normal",
      "size": "\(_size)",
      "line-height": _leading.description,
      "font-variant": _smallCaps ? "small-caps" : "normal",
    ]
  }
}

extension Text: AnyHTML {
  public var innerHTML: String? { textContent(self) }
  var tag: String { "span" }
  var attributes: [String: String] {
    var font: Font?
    var color: Color?
    var italic: Bool = false
    var weight: Font.Weight?
    var kerning: String = "normal"
    var baseline: CGFloat?
    var strikethrough: (Bool, Color?)?
    var underline: (Bool, Color?)?
    for modifier in _modifiers {
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
    let textDecoration = "\(!hasStrikethrough && !hasUnderline ? "none" : "")\(hasStrikethrough ? "line-through" : "") \(hasUnderline ? "underline" : "")"
    return [
      "style": """
      \(font?.styles.filter {
        if weight != nil {
          return $0.key != "font-weight"
        } else {
          return true
        }
              }.inlineStyles ?? "")
      color: \(color?.description ?? "inherit");
      font-style: \(italic ? "italic" : "normal");
      font-weight: \(weight?.value ?? font?._weight.value ?? 400);
      letter-spacing: \(kerning);
      vertical-align: \(baseline == nil ? "baseline" : "\(baseline!)em");
      text-decoration: \(textDecoration);
      text-decoration-color: \(strikethrough?.1?.description ?? underline?.1?.description ?? "inherit")
      """
      .split(separator: "\"")
      .joined(separator: "'"),
    ]
  }

  var listeners: [String: Listener] { [:] }
}

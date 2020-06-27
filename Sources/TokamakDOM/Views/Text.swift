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

extension Font.Design : CustomStringConvertible {
  /// Some default font stacks for the various designs
  public var description: String {
    switch self {
    case .default:
      return #"system, -apple-system, ".SFNSText-Regular", "San Francisco", "Roboto", "Segoe UI", "Helvetica Neue", "Lucida Grande", sans-serif"#
    case .monospaced:
      return #"Consolas, "Andale Mono WT", "Andale Mono", "Lucida Console", "Lucida Sans Typewriter", "DejaVu Sans Mono", "Bitstream Vera Sans Mono", "Liberation Mono", "Nimbus Mono L", Monaco, "Courier New", Courier, monospace"#
    case .rounded: // Not supported due to browsers not having a rounded font builtin
      return Self.default.description
    case .serif:
      return #"Cambria, "Hoefler Text", Utopia, "Liberation Serif", "Nimbus Roman No9 L Regular", Times, "Times New Roman", serif"#
    }
  }
}

extension Font.Leading : CustomStringConvertible {
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

extension Font : StylesConvertible {
  var styles: [String : String] {
    [
      "font-family": _name == _FontNames.system.rawValue ? _design.description : _name,
      "font-weight": "\(_bold ? 700 : _weight.value)",
      "font-style": _italic ? "italic" : "normal",
      "size": "\(_size)",
      "line-height": _leading.description,
      "font-variant": _smallCaps ? "small-caps" : "normal"
    ]
  }
}

extension Color : CustomStringConvertible {
  public var description: String {
    "rgb(\(red), \(green), \(blue), \(alpha))"
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
        case .color(let _color):
          color = _color
        case .font(let _font):
          font = _font
        case .italic:
          italic = true
        case .weight(let _weight):
          weight = _weight
        case .kerning(let _kerning), .tracking(let _kerning):
          kerning = "\(_kerning)em"
        case .baseline(let _baseline):
          baseline = _baseline
        case .rounded: break
        case .strikethrough(let active, let color):
          strikethrough = (active, color)
        case .underline(let active, let color):
          underline = (active, color)
        }
    }
    let textDecoration = strikethrough == nil && underline == nil ? "none" : """
    \((strikethrough?.0 ?? false) ? "line-through" : "") \((strikethrough?.0 ?? false) ? "underline" : "")
    """
    return [
      "style": """
              \(font?.inlineStyles ?? "")
              color: \(color?.description ?? "inherit");
              font-style: \(italic ? "italic" : "normal");
              font-weight: \(weight?.value ?? 400);
              letter-spacing: \(kerning);
              vertical-align: \(baseline == nil ? "normal" : "\(baseline!)em");
              text-decoration: \(textDecoration);
              text-decoration-color: \(strikethrough?.1?.description ?? underline?.1?.description ?? "inherit")
              """
    ]
  }
  var listeners: [String: Listener] { [:] }
}

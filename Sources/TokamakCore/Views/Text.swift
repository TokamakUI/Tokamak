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
//  Created by Max Desiatov on 08/04/2020.
//

public struct Text: View {
  let content: String
  public let _modifiers: [_Modifier]

  public enum _Modifier: Equatable {
    case color(Color?)
    case font(Font?)
    case italic
    case weight(Font.Weight?)
    case kerning(CGFloat)
    case tracking(CGFloat)
    case baseline(CGFloat)
    case rounded
//    case anyTextModifier(AnyTextModifier)
    case strikethrough(Bool, Color?) // Note: Not in SwiftUI
    case underline(Bool, Color?) // Note: Not in SwiftUI
  }

  init(content: String, modifiers: [_Modifier] = []) {
    self.content = content
    _modifiers = modifiers
  }

  public init(verbatim content: String) {
    self.init(content: content)
  }

  public init<S>(_ content: S) where S: StringProtocol {
    self.init(content: String(content))
  }

  public var body: Never {
    neverBody("Text")
  }
}

public func textContent(_ text: Text) -> String {
  text.content
}

public extension Text {
  func foregroundColor(_ color: Color?) -> Text {
    .init(content: content, modifiers: _modifiers + [.color(color)])
  }

  func font(_ font: Font?) -> Text {
    .init(content: content, modifiers: _modifiers + [.font(font)])
  }

  func fontWeight(_ weight: Font.Weight?) -> Text {
    .init(content: content, modifiers: _modifiers + [.weight(weight)])
  }

  func bold() -> Text {
    .init(content: content, modifiers: _modifiers + [.weight(.bold)])
  }

  func italic() -> Text {
    .init(content: content, modifiers: _modifiers + [.italic])
  }

  func strikethrough(_ active: Bool = true, color: Color? = nil) -> Text {
    .init(content: content, modifiers: _modifiers + [.strikethrough(active, color)])
  }

  func underline(_ active: Bool = true, color: Color? = nil) -> Text {
    .init(content: content, modifiers: _modifiers + [.underline(active, color)])
  }

  func kerning(_ kerning: CGFloat) -> Text {
    .init(content: content, modifiers: _modifiers + [.kerning(kerning)])
  }

  func tracking(_ tracking: CGFloat) -> Text {
    .init(content: content, modifiers: _modifiers + [.tracking(tracking)])
  }

  func baselineOffset(_ baselineOffset: CGFloat) -> Text {
    .init(content: content, modifiers: _modifiers + [.baseline(baselineOffset)])
  }
}

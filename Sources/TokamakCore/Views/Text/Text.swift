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

/// A view that displays one or more lines of read-only text.
///
/// You can choose a font using the `font(_:)` view modifier.
///
///     Text("Hello World")
///       .font(.title)
///
/// There are a variety of modifiers available to fully customize the type:
///
///     Text("Hello World")
///       .foregroundColor(.blue)
///       .bold()
///       .italic()
///       .underline(true, color: .red)
public struct Text: View {
  let storage: _Storage
  let modifiers: [_Modifier]

  @Environment(\.font) var font
  @Environment(\.foregroundColor) var foregroundColor
  @Environment(\.redactionReasons) var redactionReasons

  public enum _Storage {
    case verbatim(String)
    case segmentedText([Text])
  }

  public enum _Modifier: Equatable {
    case color(Color?)
    case font(Font?)
    case italic
    case weight(Font.Weight?)
    case kerning(CGFloat)
    case tracking(CGFloat)
    case baseline(CGFloat)
    case rounded
    case strikethrough(Bool, Color?) // Note: Not in SwiftUI
    case underline(Bool, Color?) // Note: Not in SwiftUI
  }

  init(storage: _Storage, modifiers: [_Modifier] = []) {
    if case let .segmentedText(segments) = storage {
      self.storage = .segmentedText(segments.map {
        Self(storage: $0.storage, modifiers: modifiers + $0.modifiers)
      })
    } else {
      self.storage = storage
    }
    self.modifiers = modifiers
  }

  public init(verbatim content: String) {
    self.init(storage: .verbatim(content))
  }

  public init<S>(_ content: S) where S: StringProtocol {
    self.init(storage: .verbatim(String(content)))
  }

  public var body: Never {
    neverBody("Text")
  }
}

/// This is a helper class that works around absence of "package private" access control in Swift
public struct _TextProxy {
  public let subject: Text

  public init(_ subject: Text) { self.subject = subject }

  public var storage: Text._Storage { subject.storage }
  public var rawText: String {
    switch subject.storage {
    case let .segmentedText(segments):
      return segments
        .map { Self($0).rawText }
        .reduce("", +)
    case let .verbatim(text):
      return text
    }
  }

  public var modifiers: [Text._Modifier] {
    [
      .font(subject.font),
      .color(subject.foregroundColor),
    ] + subject.modifiers
  }

  public var redactionReasons: RedactionReasons { subject.redactionReasons }
}

public extension Text {
  func font(_ font: Font?) -> Text {
    .init(storage: storage, modifiers: modifiers + [.font(font)])
  }

  func fontWeight(_ weight: Font.Weight?) -> Text {
    .init(storage: storage, modifiers: modifiers + [.weight(weight)])
  }

  func bold() -> Text {
    .init(storage: storage, modifiers: modifiers + [.weight(.bold)])
  }

  func italic() -> Text {
    .init(storage: storage, modifiers: modifiers + [.italic])
  }

  func strikethrough(_ active: Bool = true, color: Color? = nil) -> Text {
    .init(storage: storage, modifiers: modifiers + [.strikethrough(active, color)])
  }

  func underline(_ active: Bool = true, color: Color? = nil) -> Text {
    .init(storage: storage, modifiers: modifiers + [.underline(active, color)])
  }

  func kerning(_ kerning: CGFloat) -> Text {
    .init(storage: storage, modifiers: modifiers + [.kerning(kerning)])
  }

  func tracking(_ tracking: CGFloat) -> Text {
    .init(storage: storage, modifiers: modifiers + [.tracking(tracking)])
  }

  func baselineOffset(_ baselineOffset: CGFloat) -> Text {
    .init(storage: storage, modifiers: modifiers + [.baseline(baselineOffset)])
  }
}

extension Text {
  public static func _concatenating(lhs: Self, rhs: Self) -> Self {
    .init(storage: .segmentedText([lhs, rhs]))
  }
}

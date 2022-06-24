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
//  Created by Max Desiatov on 08/04/2020.
//

import Foundation

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
public struct Text: _PrimitiveView, Equatable {
  let storage: _Storage
  let modifiers: [_Modifier]

  @Environment(\.self)
  var environment

  public static func == (lhs: Text, rhs: Text) -> Bool {
    lhs.storage == rhs.storage
      && lhs.modifiers == rhs.modifiers
  }

  public enum _Storage: Equatable {
    case verbatim(String)
    case segmentedText([(storage: _Storage, modifiers: [_Modifier])])

    public static func == (lhs: Text._Storage, rhs: Text._Storage) -> Bool {
      switch lhs {
      case let .verbatim(lhsVerbatim):
        guard case let .verbatim(rhsVerbatim) = rhs else { return false }
        return lhsVerbatim == rhsVerbatim
      case let .segmentedText(lhsSegments):
        guard case let .segmentedText(rhsSegments) = rhs,
              lhsSegments.count == rhsSegments.count else { return false }
        return lhsSegments.enumerated().allSatisfy {
          $0.element.0 == rhsSegments[$0.offset].0
            && $0.element.1 == rhsSegments[$0.offset].1
        }
      }
    }
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
        ($0.0, modifiers + $0.1)
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
}

public extension Text._Storage {
  var rawText: String {
    switch self {
    case let .segmentedText(segments):
      return segments
        .map(\.0.rawText)
        .reduce("", +)
    case let .verbatim(text):
      return text
    }
  }
}

/// This is a helper type that works around absence of "package private" access control in Swift
public struct _TextProxy {
  public let subject: Text

  public init(_ subject: Text) {
    // Resolve the foregroundStyle.
    if let foregroundStyle = subject.environment._foregroundStyle {
      var shape = _ShapeStyle_Shape(
        for: .prepare(subject, level: 0),
        in: subject.environment,
        role: .fill
      )
      foregroundStyle._apply(to: &shape)
      if case let .prepared(text) = shape.result {
        self.subject = text
        return
      }
    }
    self.subject = subject
  }

  public var storage: Text._Storage { subject.storage }
  public var rawText: String {
    subject.storage.rawText
  }

  public var modifiers: [Text._Modifier] {
    [
      .font(subject.environment.font),
      .color(subject.environment.foregroundColor),
    ] + subject.modifiers
  }

  public var environment: EnvironmentValues { subject.environment }
}

public extension Text {
  func font(_ font: Font?) -> Text {
    .init(storage: storage, modifiers: modifiers + [.font(font)])
  }

  func foregroundColor(_ color: Color?) -> Text {
    .init(storage: storage, modifiers: modifiers + [.color(color)])
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

public extension Text {
  static func _concatenating(lhs: Self, rhs: Self) -> Self {
    .init(storage: .segmentedText([
      (lhs.storage, lhs.modifiers),
      (rhs.storage, rhs.modifiers),
    ]))
  }
}

extension Text: Layout {
  public func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) -> CGSize {
    environment.measureText(self, proposal, environment)
  }

  public func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) {
    for subview in subviews {
      subview.place(at: bounds.origin, proposal: proposal)
    }
  }
}

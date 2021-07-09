// Copyright 2018-2021 Tokamak contributors
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

/// Override `TokamakCore`'s default `Font` resolvers with a Renderer-specific one.
/// You can override a specific font box
/// (such as `_SystemFontBox`, or all boxes with `AnyFontBox`).
///
/// This extension makes all fonts monospaced:
///
///     extension AnyFontBox: AnyFontBoxDeferredToRenderer {
///       public func deferredResolve(
///         in environment: EnvironmentValues
///       ) -> AnyFontBox.ResolvedValue {
///         var font = resolve(in: environment)
///         font._design = .monospaced
///         return font
///       }
///     }
///
public protocol AnyFontBoxDeferredToRenderer: AnyFontBox {
  func deferredResolve(in environment: EnvironmentValues) -> AnyFontBox.ResolvedValue
}

public class AnyFontBox: AnyTokenBox, Hashable, Equatable {
  public struct _Font: Hashable, Equatable {
    public var _name: _FontNames
    public var _size: CGFloat
    public var _design: Font.Design
    public var _weight: Font.Weight
    public var _smallCaps: Bool
    public var _italic: Bool
    public var _bold: Bool
    public var _monospaceDigit: Bool
    public var _leading: Font.Leading

    public init(
      name: _FontNames,
      size: CGFloat,
      design: Font.Design = .default,
      weight: Font.Weight = .regular,
      smallCaps: Bool = false,
      italic: Bool = false,
      bold: Bool = false,
      monospaceDigit: Bool = false,
      leading: Font.Leading = .standard
    ) {
      _name = name
      _size = size
      _design = design
      _weight = weight
      _smallCaps = smallCaps
      _italic = italic
      _bold = bold
      _monospaceDigit = monospaceDigit
      _leading = leading
    }
  }

  public static func == (lhs: AnyFontBox, rhs: AnyFontBox) -> Bool {
    lhs.equals(rhs)
  }

  public func equals(_ other: AnyFontBox) -> Bool {
    fatalError("implement \(#function) in subclass")
  }

  public func hash(into hasher: inout Hasher) {
    fatalError("implement \(#function) in subclass")
  }

  public func resolve(in environment: EnvironmentValues) -> _Font {
    fatalError("implement \(#function) in subclass")
  }
}

public class _ConcreteFontBox: AnyFontBox {
  public let font: ResolvedValue

  public static func == (lhs: _ConcreteFontBox, rhs: _ConcreteFontBox) -> Bool {
    lhs.font == rhs.font
  }

  override public func hash(into hasher: inout Hasher) {
    hasher.combine(font)
  }

  init(_ font: ResolvedValue) {
    self.font = font
  }

  override public func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    font
  }

  override public func equals(_ other: AnyFontBox) -> Bool {
    guard let other = other as? _ConcreteFontBox else { return false }
    return other.font == font
  }
}

public class _ModifiedFontBox: AnyFontBox {
  public let provider: AnyFontBox
  public let modifier: (inout ResolvedValue) -> ()

  public static func == (lhs: _ModifiedFontBox, rhs: _ModifiedFontBox) -> Bool {
    lhs.resolve(in: EnvironmentValues()) == rhs.resolve(in: EnvironmentValues())
  }

  override public func hash(into hasher: inout Hasher) {
    hasher.combine(provider.resolve(in: EnvironmentValues()))
  }

  init(previously provider: AnyFontBox, modifier: @escaping (inout ResolvedValue) -> ()) {
    self.provider = provider
    self.modifier = modifier
  }

  override public func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    var font = provider.resolve(in: environment)
    modifier(&font)
    return font
  }

  override public func equals(_ other: AnyFontBox) -> Bool {
    guard let other = other as? _ModifiedFontBox else { return false }
    var resolved = provider.resolve(in: .init())
    modifier(&resolved)
    var otherResolved = other.provider.resolve(in: .init())
    other.modifier(&otherResolved)
    return other.provider.equals(provider) && resolved == otherResolved
  }
}

public class _SystemFontBox: AnyFontBox {
  public enum SystemFont: Equatable, Hashable {
    case largeTitle
    case title
    case title2
    case title3
    case headline
    case subheadline
    case body
    case callout
    case footnote
    case caption
    case caption2
  }

  public let value: SystemFont

  public static func == (lhs: _SystemFontBox, rhs: _SystemFontBox) -> Bool {
    lhs.value == rhs.value
  }

  override public func hash(into hasher: inout Hasher) {
    hasher.combine(value)
  }

  init(_ value: SystemFont) {
    self.value = value
  }

  override public func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    switch value {
    case .largeTitle: return .init(name: .system, size: 34)
    case .title: return .init(name: .system, size: 28)
    case .title2: return .init(name: .system, size: 22)
    case .title3: return .init(name: .system, size: 20)
    case .headline: return .init(name: .system, size: 17, design: .default, weight: .semibold)
    case .subheadline: return .init(name: .system, size: 15)
    case .body: return .init(name: .system, size: 17)
    case .callout: return .init(name: .system, size: 16)
    case .footnote: return .init(name: .system, size: 13)
    case .caption: return .init(name: .system, size: 12)
    case .caption2: return .init(name: .system, size: 11)
    }
  }

  override public func equals(_ other: AnyFontBox) -> Bool {
    guard let other = other as? _SystemFontBox else { return false }
    return other.value == value
  }
}

public class _CustomFontBox: AnyFontBox {
  public let name: String
  public let size: Size
  public enum Size: Hashable {
    // FIXME: Update size with dynamic type.
    case dynamic(CGFloat)
    case fixed(CGFloat)
  }

  // FIXME: Update size with dynamic type using `textStyle`.
  public let textStyle: Font.TextStyle?

  public static func == (lhs: _CustomFontBox, rhs: _CustomFontBox) -> Bool {
    lhs.name == rhs.name
      && lhs.size == rhs.size
      && lhs.textStyle == rhs.textStyle
  }

  override public func hash(into hasher: inout Hasher) {
    hasher.combine(name)
    hasher.combine(size)
    hasher.combine(textStyle)
  }

  init(_ name: String, size: Size, relativeTo textStyle: Font.TextStyle? = nil) {
    (self.name, self.size, self.textStyle) = (name, size, textStyle)
  }

  override public func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    switch size {
    case let .dynamic(size):
      return .init(
        name: .custom(name),
        size: size
      )
    case let .fixed(size):
      return .init(
        name: .custom(name),
        size: size
      )
    }
  }

  override public func equals(_ other: AnyFontBox) -> Bool {
    guard let other = other as? _CustomFontBox else { return false }
    return other.name == name && other.size == size && other.textStyle == textStyle
  }
}

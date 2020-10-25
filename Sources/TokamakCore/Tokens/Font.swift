// Copyright 2018-2020 Tokamak contributors
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
    public var _name: String
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
      _name = name.rawValue
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

  public static func == (lhs: AnyFontBox, rhs: AnyFontBox) -> Bool { false }
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
}

public struct Font: Hashable {
  let provider: AnyFontBox

  fileprivate init(_ provider: AnyFontBox) {
    self.provider = provider
  }

  public func italic() -> Self {
    .init(_ModifiedFontBox(previously: provider) {
      $0._italic = true
    })
  }

  public func smallCaps() -> Self {
    .init(_ModifiedFontBox(previously: provider) {
      $0._smallCaps = true
    })
  }

  public func lowercaseSmallCaps() -> Self {
    smallCaps()
  }

  public func uppercaseSmallCaps() -> Self {
    smallCaps()
  }

  public func monospacedDigit() -> Self {
    .init(_ModifiedFontBox(previously: provider) {
      $0._monospaceDigit = true
    })
  }

  public func weight(_ weight: Weight) -> Self {
    .init(_ModifiedFontBox(previously: provider) {
      $0._weight = weight
    })
  }

  public func bold() -> Self {
    .init(_ModifiedFontBox(previously: provider) {
      $0._bold = true
    })
  }

  public func leading(_ leading: Leading) -> Self {
    .init(_ModifiedFontBox(previously: provider) {
      $0._leading = leading
    })
  }
}

extension Font {
  public struct Weight: Hashable {
    public let value: Int

    public static let ultraLight: Self = .init(value: 100)
    public static let thin: Self = .init(value: 200)
    public static let light: Self = .init(value: 300)
    public static let regular: Self = .init(value: 400)
    public static let medium: Self = .init(value: 500)
    public static let semibold: Self = .init(value: 600)
    public static let bold: Self = .init(value: 700)
    public static let heavy: Self = .init(value: 800)
    public static let black: Self = .init(value: 900)
  }
}

extension Font {
  public enum Leading {
    case standard
    case tight
    case loose
  }
}

public enum _FontNames: String, CaseIterable {
  case system
}

extension Font {
  public static func system(size: CGFloat, weight: Weight = .regular,
                            design: Design = .default) -> Self
  {
    .init(
      _ConcreteFontBox(
        .init(
          name: .system,
          size: size,
          design: design,
          weight: weight,
          smallCaps: false,
          italic: false,
          bold: false,
          monospaceDigit: false,
          leading: .standard
        )
      )
    )
  }

  public enum Design: Hashable {
    case `default`
    case serif
    case rounded
    case monospaced
  }
}

extension Font {
  public static let largeTitle: Self = .init(_SystemFontBox(.largeTitle))
  public static let title: Self = .init(_SystemFontBox(.title))
  public static let title2: Self = .init(_SystemFontBox(.title2))
  public static let title3: Self = .init(_SystemFontBox(.title3))
  public static let headline: Font = .init(_SystemFontBox(.headline))
  public static let subheadline: Self = .init(_SystemFontBox(.subheadline))
  public static let body: Self = .init(_SystemFontBox(.body))
  public static let callout: Self = .init(_SystemFontBox(.callout))
  public static let footnote: Self = .init(_SystemFontBox(.footnote))
  public static let caption: Self = .init(_SystemFontBox(.caption))
  public static let caption2: Self = .init(_SystemFontBox(.caption2))

  public static func system(_ style: TextStyle, design: Design = .default) -> Self {
    .init(_ModifiedFontBox(previously: style.font.provider) {
      $0._design = design
    })
  }

  public enum TextStyle: Hashable, CaseIterable {
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

    var font: Font {
      switch self {
      case .largeTitle: return .largeTitle
      case .title: return .title
      case .title2: return .title2
      case .title3: return .title3
      case .headline: return .headline
      case .subheadline: return .subheadline
      case .body: return .body
      case .callout: return .callout
      case .footnote: return .footnote
      case .caption: return .caption
      case .caption2: return .caption2
      }
    }
  }
}

public struct _FontProxy {
  let subject: Font
  public init(_ subject: Font) { self.subject = subject }
  public func resolve(in environment: EnvironmentValues) -> AnyFontBox.ResolvedValue {
    if let deferred = subject.provider as? AnyFontBoxDeferredToRenderer {
      return deferred.deferredResolve(in: environment)
    } else {
      return subject.provider.resolve(in: environment)
    }
  }
}

struct FontKey: EnvironmentKey {
  static let defaultValue: Font? = nil
}

public extension EnvironmentValues {
  var font: Font? {
    get {
      self[FontKey.self]
    }
    set {
      self[FontKey.self] = newValue
    }
  }
}

public extension View {
  func font(_ font: Font?) -> some View {
    environment(\.font, font)
  }
}

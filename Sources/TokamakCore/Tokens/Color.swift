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
//
//  Created by Max Desiatov on 16/10/2018.
//

/// Override `TokamakCore`'s default `Color` resolvers with a Renderer-specific one.
/// You can override a specific color box
/// (such as `_SystemColorBox`, or all boxes with `AnyColorBox`).
///
/// This extension makes all system colors red:
///
///     extension _SystemColorBox: AnyColorBoxDeferredToRenderer {
///       public func deferredResolve(
///         in environment: EnvironmentValues
///       ) -> AnyColorBox.ResolvedValue {
///         return .init(
///           red: 1,
///           green: 0,
///           blue: 0,
///           opacity: 1,
///           space: .sRGB
///         )
///       }
///     }
///
public protocol AnyColorBoxDeferredToRenderer: AnyColorBox {
  func deferredResolve(in environment: EnvironmentValues) -> AnyColorBox.ResolvedValue
}

public class AnyColorBox: AnyTokenBox, Equatable {
  public struct _RGBA: Hashable, Equatable {
    public let red: Double
    public let green: Double
    public let blue: Double
    public let opacity: Double
    public let space: Color.RGBColorSpace
    public init(
      red: Double,
      green: Double,
      blue: Double,
      opacity: Double,
      space: Color.RGBColorSpace
    ) {
      self.red = red
      self.green = green
      self.blue = blue
      self.opacity = opacity
      self.space = space
    }
  }

  public static func == (lhs: AnyColorBox, rhs: AnyColorBox) -> Bool {
    lhs.equals(rhs)
  }

  /// We use a function separate from `==` so that subclasses can override the equality checks.
  public func equals(_ other: AnyColorBox) -> Bool {
    fatalError("implement \(#function) in subclass")
  }

  public func hash(into hasher: inout Hasher) {
    fatalError("implement \(#function) in subclass")
  }

  public func resolve(in environment: EnvironmentValues) -> _RGBA {
    fatalError("implement \(#function) in subclass")
  }
}

public class _ConcreteColorBox: AnyColorBox {
  public let rgba: AnyColorBox._RGBA

  override public func equals(_ other: AnyColorBox) -> Bool {
    guard let other = other as? _ConcreteColorBox
    else { return false }
    return rgba == other.rgba
  }

  override public func hash(into hasher: inout Hasher) {
    hasher.combine(rgba)
  }

  init(_ rgba: AnyColorBox._RGBA) {
    self.rgba = rgba
  }

  override public func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    rgba
  }
}

public class _EnvironmentDependentColorBox: AnyColorBox {
  public let resolver: (EnvironmentValues) -> Color

  override public func equals(_ other: AnyColorBox) -> Bool {
    guard let other = other as? _EnvironmentDependentColorBox
    else { return false }
    return resolver(EnvironmentValues()) == other.resolver(EnvironmentValues())
  }

  override public func hash(into hasher: inout Hasher) {
    hasher.combine(resolver(EnvironmentValues()))
  }

  init(_ resolver: @escaping (EnvironmentValues) -> Color) {
    self.resolver = resolver
  }

  override public func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    resolver(environment).provider.resolve(in: environment)
  }
}

public class _SystemColorBox: AnyColorBox, CustomStringConvertible {
  public enum SystemColor: String, Equatable, Hashable {
    case clear
    case black
    case white
    case gray
    case red
    case green
    case blue
    case orange
    case yellow
    case pink
    case purple
    case primary
    case secondary
  }

  public var description: String {
    value.rawValue
  }

  public let value: SystemColor

  override public func equals(_ other: AnyColorBox) -> Bool {
    guard let other = other as? _SystemColorBox
    else { return false }
    return value == other.value
  }

  override public func hash(into hasher: inout Hasher) {
    hasher.combine(value)
  }

  fileprivate init(_ value: SystemColor) {
    self.value = value
  }

  override public func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    switch environment.colorScheme {
    case .light:
      switch value {
      case .clear: return .init(red: 0, green: 0, blue: 0, opacity: 0, space: .sRGB)
      case .black: return .init(red: 0, green: 0, blue: 0, opacity: 1, space: .sRGB)
      case .white: return .init(red: 1, green: 1, blue: 1, opacity: 1, space: .sRGB)
      case .gray: return .init(red: 0.55, green: 0.55, blue: 0.57, opacity: 1, space: .sRGB)
      case .red: return .init(red: 1, green: 0.23, blue: 0.19, opacity: 1, space: .sRGB)
      case .green: return .init(red: 0.21, green: 0.78, blue: 0.35, opacity: 1, space: .sRGB)
      case .blue: return .init(red: 0.01, green: 0.48, blue: 1, opacity: 1, space: .sRGB)
      case .orange: return .init(red: 1, green: 0.58, blue: 0, opacity: 1, space: .sRGB)
      case .yellow: return .init(red: 1, green: 0.8, blue: 0, opacity: 1, space: .sRGB)
      case .pink: return .init(red: 1, green: 0.17, blue: 0.33, opacity: 1, space: .sRGB)
      case .purple: return .init(red: 0.69, green: 0.32, blue: 0.87, opacity: 1, space: .sRGB)
      case .primary: return .init(red: 0, green: 0, blue: 0, opacity: 1, space: .sRGB)
      case .secondary: return .init(red: 0.55, green: 0.55, blue: 0.57, opacity: 1, space: .sRGB)
      }
    case .dark:
      switch value {
      case .clear: return .init(red: 0, green: 0, blue: 0, opacity: 0, space: .sRGB)
      case .black: return .init(red: 0, green: 0, blue: 0, opacity: 1, space: .sRGB)
      case .white: return .init(red: 1, green: 1, blue: 1, opacity: 1, space: .sRGB)
      case .gray: return .init(red: 0.55, green: 0.55, blue: 0.57, opacity: 1, space: .sRGB)
      case .red: return .init(red: 1, green: 0.27, blue: 0.23, opacity: 1, space: .sRGB)
      case .green: return .init(red: 0.19, green: 0.82, blue: 0.35, opacity: 1, space: .sRGB)
      case .blue: return .init(red: 0.04, green: 0.52, blue: 1.00, opacity: 1, space: .sRGB)
      case .orange: return .init(red: 1, green: 0.62, blue: 0.04, opacity: 1, space: .sRGB)
      case .yellow: return .init(red: 1, green: 0.84, blue: 0.04, opacity: 1, space: .sRGB)
      case .pink: return .init(red: 1, green: 0.22, blue: 0.37, opacity: 1, space: .sRGB)
      case .purple: return .init(red: 0.75, green: 0.35, blue: 0.95, opacity: 1, space: .sRGB)
      case .primary: return .init(red: 1, green: 1, blue: 1, opacity: 1, space: .sRGB)
      case .secondary: return .init(red: 0.55, green: 0.55, blue: 0.57, opacity: 1, space: .sRGB)
      }
    }
  }
}

public struct Color: Hashable, Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.provider == rhs.provider
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(provider)
  }

  let provider: AnyColorBox

  private init(_ provider: AnyColorBox) {
    self.provider = provider
  }

  public init(
    _ colorSpace: RGBColorSpace = .sRGB,
    red: Double,
    green: Double,
    blue: Double,
    opacity: Double = 1
  ) {
    self.init(_ConcreteColorBox(
      .init(red: red, green: green, blue: blue, opacity: opacity, space: colorSpace)
    ))
  }

  public init(_ colorSpace: RGBColorSpace = .sRGB, white: Double, opacity: Double = 1) {
    self.init(colorSpace, red: white, green: white, blue: white, opacity: opacity)
  }

  // Source for the formula:
  // https://en.wikipedia.org/wiki/HSL_and_HSV#HSL_to_RGB_alternative
  public init(hue: Double, saturation: Double, brightness: Double, opacity: Double = 1) {
    let a = saturation * min(brightness / 2, 1 - (brightness / 2))
    let f = { (n: Int) -> Double in
      let k = Double((n + Int(hue * 12)) % 12)
      return brightness - (a * max(-1, min(k - 3, 9 - k, 1)))
    }
    self.init(.sRGB, red: f(0), green: f(8), blue: f(4), opacity: opacity)
  }

  /// Create a `Color` dependent on the current `ColorScheme`.
  @_spi(TokamakCore)
  public static func _withScheme(_ resolver: @escaping (ColorScheme) -> Self) -> Self {
    .init(_EnvironmentDependentColorBox {
      resolver($0.colorScheme)
    })
  }
}

public struct _ColorProxy {
  let subject: Color
  public init(_ subject: Color) { self.subject = subject }
  public func resolve(in environment: EnvironmentValues) -> AnyColorBox.ResolvedValue {
    if let deferred = subject.provider as? AnyColorBoxDeferredToRenderer {
      return deferred.deferredResolve(in: environment)
    } else {
      return subject.provider.resolve(in: environment)
    }
  }
}

public extension Color {
  enum RGBColorSpace {
    case sRGB
    case sRGBLinear
    case displayP3
  }
}

extension Color: CustomStringConvertible {
  public var description: String {
    if let providerDescription = provider as? CustomStringConvertible {
      return providerDescription.description
    } else {
      return "Color: \(provider.self)"
    }
  }
}

public extension Color {
  private init(systemColor: _SystemColorBox.SystemColor) {
    self.init(_SystemColorBox(systemColor))
  }

  static let clear: Self = .init(systemColor: .clear)
  static let black: Self = .init(systemColor: .black)
  static let white: Self = .init(systemColor: .white)
  static let gray: Self = .init(systemColor: .gray)
  static let red: Self = .init(systemColor: .red)
  static let green: Self = .init(systemColor: .green)
  static let blue: Self = .init(systemColor: .blue)
  static let orange: Self = .init(systemColor: .orange)
  static let yellow: Self = .init(systemColor: .yellow)
  static let pink: Self = .init(systemColor: .pink)
  static let purple: Self = .init(systemColor: .purple)
  static let primary: Self = .init(systemColor: .primary)

  static let secondary: Self = .init(systemColor: .secondary)
  static let accentColor: Self = .init(_EnvironmentDependentColorBox {
    ($0.accentColor ?? Self.blue)
  })

  init(_ color: UIColor) {
    self = color.color
  }
}

extension Color: ExpressibleByIntegerLiteral {
  /// Allows initializing value of `Color` type from hex values
  public init(integerLiteral bitMask: UInt32) {
    self.init(
      .sRGB,
      red: Double((bitMask & 0xFF0000) >> 16) / 255,
      green: Double((bitMask & 0x00FF00) >> 8) / 255,
      blue: Double(bitMask & 0x0000FF) / 255,
      opacity: 1
    )
  }
}

public extension Color {
  init?(hex: String) {
    let cArray = Array(hex.count > 6 ? String(hex.dropFirst()) : hex)

    guard cArray.count == 6 else { return nil }

    guard
      let red = Int(String(cArray[0...1]), radix: 16),
      let green = Int(String(cArray[2...3]), radix: 16),
      let blue = Int(String(cArray[4...5]), radix: 16)
    else {
      return nil
    }
    self.init(
      .sRGB,
      red: Double(red) / 255,
      green: Double(green) / 255,
      blue: Double(blue) / 255,
      opacity: 1
    )
  }
}

extension Color: ShapeStyle {}
extension Color: View {
  @_spi(TokamakCore)
  public var body: some View {
    _ShapeView(shape: Rectangle(), style: self)
  }
}

struct AccentColorKey: EnvironmentKey {
  static let defaultValue: Color? = nil
}

public extension EnvironmentValues {
  var accentColor: Color? {
    get {
      self[AccentColorKey.self]
    }
    set {
      self[AccentColorKey.self] = newValue
    }
  }
}

public extension View {
  func accentColor(_ accentColor: Color?) -> some View {
    environment(\.accentColor, accentColor)
  }
}

struct ForegroundColorKey: EnvironmentKey {
  static let defaultValue: Color? = nil
}

public extension EnvironmentValues {
  var foregroundColor: Color? {
    get {
      self[ForegroundColorKey.self]
    }
    set {
      self[ForegroundColorKey.self] = newValue
    }
  }
}

public extension View {
  func foregroundColor(_ color: Color?) -> some View {
    environment(\.foregroundColor, color)
  }
}

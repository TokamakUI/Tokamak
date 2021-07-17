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
//  Created by Carson Katri on 7/12/21.
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

public class AnyColorBox: AnyTokenBox, Hashable {
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

public final class _ConcreteColorBox: AnyColorBox {
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

public final class _EnvironmentDependentColorBox: AnyColorBox {
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

public final class _OpacityColorBox: AnyColorBox {
  public let parent: AnyColorBox
  public let opacity: Double

  override public func equals(_ other: AnyColorBox) -> Bool {
    guard let other = other as? _OpacityColorBox
    else { return false }
    return parent.equals(other.parent) && opacity == other.opacity
  }

  override public func hash(into hasher: inout Hasher) {
    hasher.combine(parent)
    hasher.combine(opacity)
  }

  init(_ parent: AnyColorBox, opacity: Double) {
    self.parent = parent
    self.opacity = opacity
  }

  override public func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    let resolved = parent.resolve(in: environment)
    return .init(
      red: resolved.red,
      green: resolved.green,
      blue: resolved.blue,
      opacity: opacity,
      space: resolved.space
    )
  }
}

public final class _SystemColorBox: AnyColorBox, CustomStringConvertible {
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

  init(_ value: SystemColor) {
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

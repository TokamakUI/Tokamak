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
//  Created by Carson Katri on 7/6/21.
//

import Foundation

public protocol ShapeStyle {
  func _apply(to shape: inout _ShapeStyle_Shape)
  static func _apply(to type: inout _ShapeStyle_ShapeType)
}

public struct AnyShapeStyle: ShapeStyle {
  let styles: [ShapeStyle]
  let environment: EnvironmentValues

  public func _apply(to shape: inout _ShapeStyle_Shape) {
    shape.environment = environment
    if styles.count > 1 {
      let results = styles.map { style -> _ShapeStyle_Shape.Result in
        var copy = shape
        style._apply(to: &copy)
        return copy.result
      }
      shape
        .result =
        .resolved(.array(results.compactMap { $0.resolvedStyle(on: shape, in: environment) }))
    } else if let first = styles.first {
      first._apply(to: &shape)
    }

    switch shape.operation {
    case let .prepare(text, level):
      var modifiers = text.modifiers
      if let color = shape.result.resolvedStyle(on: shape, in: environment)?.color(at: level) {
        modifiers.insert(.color(color), at: 0)
      }
      shape.result = .prepared(Text(storage: text.storage, modifiers: modifiers))
    case let .resolveStyle(levels):
      if case let .resolved(resolved) = shape.result {
        if case let .array(children) = resolved {
          shape.result = .resolved(.array(.init(children[levels])))
        }
      } else if let resolved = shape.result.resolvedStyle(on: shape, in: environment) {
        shape.result = .resolved(resolved)
      }
    default:
      // TODO: Handle other operations.
      break
    }
  }

  public static func _apply(to type: inout _ShapeStyle_ShapeType) {}
}

public struct _ShapeStyle_Shape {
  public let operation: Operation
  public var result: Result
  public var environment: EnvironmentValues
  public var bounds: CGRect?
  public var role: ShapeRole
  public var inRecursiveStyle: Bool

  public init(
    for operation: Operation,
    in environment: EnvironmentValues,
    role: ShapeRole
  ) {
    self.operation = operation
    result = .none
    self.environment = environment
    bounds = nil
    self.role = role
    inRecursiveStyle = false
  }

  public enum Operation {
    case prepare(Text, level: Int)
    case resolveStyle(levels: Range<Int>)
    case fallbackColor(level: Int)
    case multiLevel
    case copyForeground
    case primaryStyle
    case modifyBackground
  }

  public enum Result {
    case prepared(Text)
    case resolved(_ResolvedStyle)
    case style(AnyShapeStyle)
    case color(Color)
    case bool(Bool)
    case none

    public func resolvedStyle(on shape: _ShapeStyle_Shape,
                              in environment: EnvironmentValues) -> _ResolvedStyle?
    {
      switch self {
      case let .resolved(resolved): return resolved
      case let .style(anyStyle):
        var copy = shape
        anyStyle._apply(to: &copy)
        return copy.result.resolvedStyle(on: shape, in: environment)
      case let .color(color):
        return .color(color.provider.resolve(in: environment))
      default:
        return nil
      }
    }
  }
}

public struct _ShapeStyle_ShapeType {}

public indirect enum _ResolvedStyle {
  case color(AnyColorBox.ResolvedValue)
//  case paint(AnyResolvedPaint) // I think is used for Image as a ShapeStyle (SwiftUI.ImagePaint).
  // TODO: Material
//  case foregroundMaterial(AnyColorBox.ResolvedValue, MaterialStyle)
//  case backgroundMaterial(AnyColorBox.ResolvedValue)
  case array([_ResolvedStyle])
  case opacity(Float, _ResolvedStyle)
//  case multicolor(ResolvedMulticolorStyle)

  public func color(at level: Int) -> Color? {
    switch self {
    case let .color(resolved):
      return Color(_ConcreteColorBox(resolved))
    case let .array(children):
      return children[level].color(at: level)
    case let .opacity(opacity, resolved):
      guard let color = resolved.color(at: level) else { return nil }
      return color.opacity(Double(opacity))
    }
  }
}

extension EnvironmentValues {
  private struct ForegroundStyleKey: EnvironmentKey {
    static let defaultValue: AnyShapeStyle? = nil
  }

  public var _foregroundStyle: AnyShapeStyle? {
    get {
      self[ForegroundStyleKey.self]
    }
    set {
      self[ForegroundStyleKey.self] = newValue
    }
  }
}

public extension View {
  @inlinable
  func foregroundStyle<S>(_ style: S) -> some View
    where S: ShapeStyle
  {
    foregroundStyle(style, style, style)
  }

  @inlinable
  func foregroundStyle<S1, S2>(_ primary: S1, _ secondary: S2) -> some View
    where S1: ShapeStyle, S2: ShapeStyle
  {
    foregroundStyle(primary, secondary, secondary)
  }

  @inlinable
  func foregroundStyle<S1, S2, S3>(_ primary: S1, _ secondary: S2,
                                   _ tertiary: S3) -> some View
    where S1: ShapeStyle, S2: ShapeStyle, S3: ShapeStyle
  {
    modifier(_ForegroundStyleModifier(styles: [primary, secondary, tertiary]))
  }
}

@frozen public struct _ForegroundStyleModifier: ViewModifier, EnvironmentModifier {
  public var styles: [ShapeStyle]

  @inlinable
  public init(styles: [ShapeStyle]) {
    self.styles = styles
  }

  public typealias Body = Never

  public func modifyEnvironment(_ values: inout EnvironmentValues) {
    var styles = self.styles
    // Passthrough inert styles.
    if styles[0] is PrimaryContentStyle {
      styles[0] = values._foregroundStyle?.styles[0] ?? styles[0]
    }
    if styles[1] is SecondaryContentStyle {
      styles[1] = values._foregroundStyle?.styles[1] ?? styles[1]
    }
    if styles[2] is TertiaryContentStyle {
      styles[2] = values._foregroundStyle?.styles[2] ?? styles[2]
    }
    if styles[0] is QuaternaryContentStyle,
       styles[1] is QuaternaryContentStyle,
       styles[2] is QuaternaryContentStyle
    {
      styles[2] = values._foregroundStyle?.styles[2] ?? styles[2]
    }
    values._foregroundStyle = .init(styles: styles, environment: values)
  }
}
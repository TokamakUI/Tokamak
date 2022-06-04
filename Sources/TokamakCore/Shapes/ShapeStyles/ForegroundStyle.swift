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

public struct ForegroundStyle: ShapeStyle {
  public init() {}

  public func _apply(to shape: inout _ShapeStyle_Shape) {
    if let foregroundStyle = shape.environment._foregroundStyle {
      foregroundStyle._apply(to: &shape)
    } else {
      shape.result = .color(shape.environment.foregroundColor ?? .primary)
    }
  }

  public static func _apply(to shape: inout _ShapeStyle_ShapeType) {}
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
  func foregroundStyle<S1, S2, S3>(
    _ primary: S1,
    _ secondary: S2,
    _ tertiary: S3
  ) -> some View
    where S1: ShapeStyle, S2: ShapeStyle, S3: ShapeStyle
  {
    modifier(_ForegroundStyleModifier(primary: primary, secondary: secondary, tertiary: tertiary))
  }
}

@frozen
public struct _ForegroundStyleModifier<
  Primary, Secondary, Tertiary
>: ViewModifier, _EnvironmentModifier
  where Primary: ShapeStyle, Secondary: ShapeStyle, Tertiary: ShapeStyle
{
  public var primary: Primary
  public var secondary: Secondary
  public var tertiary: Tertiary

  @inlinable
  public init(
    primary: Primary,
    secondary: Secondary,
    tertiary: Tertiary
  ) {
    (self.primary, self.secondary, self.tertiary) = (primary, secondary, tertiary)
  }

  public typealias Body = Never
  public func modifyEnvironment(_ values: inout EnvironmentValues) {
    values._foregroundStyle = .init(
      styles: (primary, secondary, tertiary, tertiary),
      environment: values
    )
  }
}

public extension ShapeStyle where Self == ForegroundStyle {
  static var foreground: Self { .init() }
}

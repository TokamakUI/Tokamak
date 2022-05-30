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

public struct BackgroundStyle: ShapeStyle {
  public init() {}

  public func _apply(to shape: inout _ShapeStyle_Shape) {
    if let backgroundStyle = shape.environment._backgroundStyle {
      backgroundStyle._apply(to: &shape)
    } else {
      shape.result = .none
    }
  }

  public static func _apply(to shape: inout _ShapeStyle_ShapeType) {}
}

extension EnvironmentValues {
  private struct BackgroundStyleKey: EnvironmentKey {
    static let defaultValue: AnyShapeStyle? = nil
  }

  public var _backgroundStyle: AnyShapeStyle? {
    get {
      self[BackgroundStyleKey.self]
    }
    set {
      self[BackgroundStyleKey.self] = newValue
    }
  }
}

public extension View {
  @inlinable
  func background() -> some View {
    modifier(_BackgroundStyleModifier(style: BackgroundStyle()))
  }

  @inlinable
  func background<S>(_ style: S) -> some View where S: ShapeStyle {
    modifier(_BackgroundStyleModifier(style: style))
  }
}

@frozen
public struct _BackgroundStyleModifier<Style>: ViewModifier, _EnvironmentModifier,
  EnvironmentReader
  where Style: ShapeStyle
{
  public var environment: EnvironmentValues!
  public var style: Style

  @inlinable
  public init(style: Style) {
    self.style = style
  }

  public typealias Body = Never
  public mutating func setContent(from values: EnvironmentValues) {
    environment = values
  }

  public func modifyEnvironment(_ values: inout EnvironmentValues) {
    values._backgroundStyle = .init(
      styles: (primary: style, secondary: style, tertiary: style, quaternary: style),
      environment: values
    )
  }
}

public extension ShapeStyle where Self == BackgroundStyle {
  static var background: Self { .init() }
}

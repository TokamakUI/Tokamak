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
//  Created by Carson Katri on 7/7/21.
//

@frozen public struct PrimaryContentStyle {
  @inlinable
  public init() {}
}

extension PrimaryContentStyle: ShapeStyle {
  public func _apply(to shape: inout _ShapeStyle_Shape) {
    if !shape.inRecursiveStyle,
       let foregroundStyle = shape.environment._foregroundStyle
    {
      if foregroundStyle.styles[0] is Self {
        shape.inRecursiveStyle = true
      }
      foregroundStyle.styles[0]._apply(to: &shape)
    } else {
      shape.result = .color(shape.environment.foregroundColor ?? .primary)
    }
  }

  public static func _apply(to shape: inout _ShapeStyle_ShapeType) {}
}

@frozen public struct SecondaryContentStyle {
  @inlinable
  public init() {}
}

extension SecondaryContentStyle: ShapeStyle {
  public func _apply(to shape: inout _ShapeStyle_Shape) {
    if !shape.inRecursiveStyle,
       let foregroundStyle = shape.environment._foregroundStyle
    {
      if foregroundStyle.styles[1] is Self {
        shape.inRecursiveStyle = true
      }
      foregroundStyle.styles[1]._apply(to: &shape)
    } else {
      shape.result = .color((shape.environment.foregroundColor ?? .primary).opacity(0.5))
    }
  }

  public static func _apply(to shape: inout _ShapeStyle_ShapeType) {}
}

@frozen public struct TertiaryContentStyle {
  @inlinable
  public init() {}
}

extension TertiaryContentStyle: ShapeStyle {
  public func _apply(to shape: inout _ShapeStyle_Shape) {
    if !shape.inRecursiveStyle,
       let foregroundStyle = shape.environment._foregroundStyle
    {
      if foregroundStyle.styles[2] is Self {
        shape.inRecursiveStyle = true
      }
      foregroundStyle.styles[2]._apply(to: &shape)
    } else {
      shape.result = .color((shape.environment.foregroundColor ?? .primary).opacity(0.3))
    }
  }

  public static func _apply(to shape: inout _ShapeStyle_ShapeType) {}
}

@frozen public struct QuaternaryContentStyle {
  @inlinable
  public init() {}
}

extension QuaternaryContentStyle: ShapeStyle {
  public func _apply(to shape: inout _ShapeStyle_Shape) {
    if !shape.inRecursiveStyle,
       let foregroundStyle = shape.environment._foregroundStyle
    {
      if foregroundStyle.styles[2] is Self {
        shape.inRecursiveStyle = true
      }
      foregroundStyle.styles[2]._apply(to: &shape)
    } else {
      shape.result = .color((shape.environment.foregroundColor ?? .primary).opacity(0.2))
    }
  }

  public static func _apply(to shape: inout _ShapeStyle_ShapeType) {}
}

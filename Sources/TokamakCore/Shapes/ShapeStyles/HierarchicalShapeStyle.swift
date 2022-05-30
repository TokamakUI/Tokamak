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

/// A `ShapeStyle` that provides the `primary`, `secondary`, `tertiary`, and `quaternary` styles.
@frozen
public struct HierarchicalShapeStyle: ShapeStyle {
  @usableFromInline
  internal var id: UInt32

  @inlinable
  internal init(id: UInt32) {
    self.id = id
  }

  public func _apply(to shape: inout _ShapeStyle_Shape) {
    if let foregroundStyle = shape.environment._foregroundStyle,
       foregroundStyle.stylesArray.count > id
    {
      let style = foregroundStyle.stylesArray[Int(id)]
      if (style as? Self)?.id == id {
        shape.inRecursiveStyle = true
        // Walk up.
        shape.environment = foregroundStyle.environment
      }
      style._apply(to: &shape)
    } else {
      // Fallback to changing the opacity of the `foregroundColor`.
      shape.result = .color(
        (shape.environment.foregroundColor ?? .primary)
          .opacity({
            switch id {
            case 0: return 1
            case 1: return 0.5
            case 2: return 0.3
            default: return 0.2
            }
          }())
      )
    }
  }

  public static func _apply(to type: inout _ShapeStyle_ShapeType) {}
}

public extension ShapeStyle where Self == HierarchicalShapeStyle {
  static var primary: HierarchicalShapeStyle { .init(id: 0) }
  static var secondary: HierarchicalShapeStyle { .init(id: 1) }
  static var tertiary: HierarchicalShapeStyle { .init(id: 2) }
  static var quaternary: HierarchicalShapeStyle { .init(id: 3) }
}

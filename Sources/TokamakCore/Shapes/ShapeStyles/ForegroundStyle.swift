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

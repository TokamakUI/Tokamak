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

public struct Material {
  private let style: _MaterialStyle

  private init(_ style: _MaterialStyle) {
    self.style = style
  }

  public static let regular = Self(.regular)
  public static let thick = Self(.thick)
  public static let thin = Self(.thin)
  public static let ultraThin = Self(.ultraThin)
  public static let ultraThick = Self(.ultraThick)
}

public enum _MaterialStyle {
  case regular
  case thick
  case thin
  case ultraThin
  case ultraThick
}

extension Material: ShapeStyle {
  public func _apply(to shape: inout _ShapeStyle_Shape) {
    shape.result = .resolved(
      .foregroundMaterial(
        _ColorProxy(Color._withScheme {
          $0 == .light ? Color.white : Color.black
        }).resolve(in: shape.environment),
        style
      )
    )
  }

  public static func _apply(to shape: inout _ShapeStyle_ShapeType) {}
}

public extension Material {
  static let bar = Self.regular
}

public extension ShapeStyle where Self == Material {
  static var regularMaterial: Self { .regular }
  static var thickMaterial: Self { .thick }
  static var thinMaterial: Self { .thin }
  static var ultraThinMaterial: Self { .ultraThin }
  static var ultraThickMaterial: Self { .ultraThick }
  static var bar: Self { .bar }
}

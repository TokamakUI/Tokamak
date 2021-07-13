// Copyright 2021 Tokamak contributors
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

import Foundation

public struct _ShadowEffect: EnvironmentalModifier, Equatable {
  public var color: Color
  public var radius: CGFloat
  public var offset: CGSize

  @inlinable
  init(
    color: Color,
    radius: CGFloat,
    offset: CGSize
  ) {
    self.color = color
    self.radius = radius
    self.offset = offset
  }

  public func resolve(in environment: EnvironmentValues) -> _Resolved {
    .init(
      color: color.provider.resolve(in: environment),
      radius: radius,
      offset: offset
    )
  }

  public struct _Resolved: ViewModifier, Animatable {
    public var color: AnyColorBox.ResolvedValue
    public var radius: CGFloat
    public var offset: CGSize

    public func body(content: Content) -> some View {
      content
    }

    public typealias AnimatableData = AnimatablePair<
      AnimatablePair<
        Float,
        AnimatablePair<
          Float,
          AnimatablePair<Float, Float>
        >
      >,
      AnimatablePair<CGFloat, CGSize.AnimatableData>
    >
    public var animatableData: _Resolved.AnimatableData {
      get {
        .init(
          .init(
            Float(color.red),
            .init(
              Float(color.green),
              .init(
                Float(color.blue),
                Float(color.opacity)
              )
            )
          ),
          .init(radius, offset.animatableData)
        )
      }
      set {
        color = .init(
          red: Double(newValue[].0[].0),
          green: Double(newValue[].0[].1[].0),
          blue: Double(newValue[].0[].1[].1[].0),
          opacity: Double(newValue[].0[].1[].1[].1),
          space: .sRGB
        )
        (radius, offset.animatableData) = newValue[].1[]
      }
    }
  }
}

public extension View {
  @inlinable
  func shadow(
    color: Color = Color(.sRGBLinear, white: 0, opacity: 0.33),
    radius: CGFloat,
    x: CGFloat = 0,
    y: CGFloat = 0
  ) -> some View {
    modifier(
      _ShadowEffect(
        color: color,
        radius: radius,
        offset: .init(width: x, height: y)
      )
    )
  }
}

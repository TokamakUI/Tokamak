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

public struct _ShadowLayout: ViewModifier, EnvironmentReader {
  public var color: Color
  public var radius: CGFloat
  public var x: CGFloat
  public var y: CGFloat
  public var environment: EnvironmentValues!

  public func body(content: Content) -> some View {
    content
  }

  mutating func setContent(from values: EnvironmentValues) {
    environment = values
  }
}

public extension View {
  func shadow(
    color: Color = Color(.sRGBLinear, white: 0, opacity: 0.33),
    radius: CGFloat,
    x: CGFloat = 0,
    y: CGFloat = 0
  ) -> some View {
    modifier(_ShadowLayout(color: color, radius: radius, x: x, y: y))
  }
}

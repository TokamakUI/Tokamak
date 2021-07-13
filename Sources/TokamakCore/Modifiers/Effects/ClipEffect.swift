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
//  Created by Carson Katri on 06/29/2020.
//

import Foundation

public struct _ClipEffect<ClipShape>: ViewModifier where ClipShape: Shape {
  public var shape: ClipShape
  public var style: FillStyle

  public init(shape: ClipShape, style: FillStyle = FillStyle()) {
    self.shape = shape
    self.style = style
  }

  public func body(content: Content) -> some View {
    content
  }

  public var animatableData: ClipShape.AnimatableData {
    get { shape.animatableData }
    set { shape.animatableData = newValue }
  }
}

public extension View {
  func clipShape<S>(_ shape: S, style: FillStyle = FillStyle()) -> some View where S: Shape {
    modifier(_ClipEffect(shape: shape, style: style))
  }

  func clipped(antialiased: Bool = false) -> some View {
    clipShape(
      Rectangle(),
      style: FillStyle(antialiased: antialiased)
    )
  }

  func cornerRadius(_ radius: CGFloat, antialiased: Bool = true) -> some View {
    clipShape(
      RoundedRectangle(cornerRadius: radius),
      style: FillStyle(antialiased: antialiased)
    )
  }
}

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
//  Created by Carson Katri on 7/9/21.
//

import Foundation

@frozen
public struct _ScaleEffect: GeometryEffect, Equatable {
  public var scale: CGSize
  public var anchor: UnitPoint

  @inlinable
  public init(scale: CGSize, anchor: UnitPoint = .center) {
    self.scale = scale
    self.anchor = anchor
  }

  public func effectValue(size: CGSize) -> ProjectionTransform {
    .init(.init(scaleX: scale.width, y: scale.height))
  }

  public func body(content: Content) -> some View {
    content
  }
}

public extension View {
  @inlinable
  func scaleEffect(_ scale: CGSize, anchor: UnitPoint = .center) -> some View {
    modifier(_ScaleEffect(scale: scale, anchor: anchor))
  }

  @inlinable
  func scaleEffect(_ s: CGFloat, anchor: UnitPoint = .center) -> some View {
    scaleEffect(CGSize(width: s, height: s), anchor: anchor)
  }

  @inlinable
  func scaleEffect(
    x: CGFloat = 1.0,
    y: CGFloat = 1.0,
    anchor: UnitPoint = .center
  ) -> some View {
    scaleEffect(CGSize(width: x, height: y), anchor: anchor)
  }
}

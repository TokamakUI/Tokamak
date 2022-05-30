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
//  Created by Carson Katri on 7/12/21.
//

import Foundation

@frozen
public struct _OffsetEffect: GeometryEffect, Equatable {
  public var offset: CGSize

  @inlinable
  public init(offset: CGSize) {
    self.offset = offset
  }

  public func effectValue(size: CGSize) -> ProjectionTransform {
    .init(.init(translationX: offset.width, y: offset.height))
  }

  public var animatableData: CGSize.AnimatableData {
    get {
      offset.animatableData
    }
    set {
      offset.animatableData = newValue
    }
  }

  public func body(content: Content) -> some View {
    content
  }
}

public extension View {
  @inlinable
  func offset(_ offset: CGSize) -> some View {
    modifier(_OffsetEffect(offset: offset))
  }

  @inlinable
  func offset(x: CGFloat = 0, y: CGFloat = 0) -> some View {
    offset(CGSize(width: x, height: y))
  }
}

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
//  Created by Carson Katri on 06/28/2020.
//

import Foundation

public struct _StrokedShape<S>: Shape, DynamicProperty where S: Shape {
  @Environment(\.self)
  public var environment

  public var shape: S
  public var style: StrokeStyle

  public init(shape: S, style: StrokeStyle) {
    self.shape = shape
    self.style = style
  }

  public func path(in rect: CGRect) -> Path {
    shape
      .path(in: rect)
      .strokedPath(style)
  }

  public static var role: ShapeRole { .stroke }

  public typealias AnimatableData = AnimatablePair<S.AnimatableData, StrokeStyle.AnimatableData>
  public var animatableData: AnimatableData {
    get {
      .init(shape.animatableData, style.animatableData)
    }
    set {
      (shape.animatableData, style.animatableData) = newValue[]
    }
  }
}

public struct _TrimmedShape<S>: Shape where S: Shape {
  public var shape: S
  public var startFraction: CGFloat
  public var endFraction: CGFloat

  public init(shape: S, startFraction: CGFloat = 0, endFraction: CGFloat = 1) {
    self.shape = shape
    self.startFraction = startFraction
    self.endFraction = endFraction
  }

  public func path(in rect: CGRect) -> Path {
    shape
      .path(in: rect)
      .trimmedPath(from: startFraction, to: endFraction)
  }

  public typealias AnimatableData = AnimatablePair<
    S.AnimatableData,
    AnimatablePair<CGFloat, CGFloat>
  >
  public var animatableData: AnimatableData {
    get {
      .init(shape.animatableData, .init(startFraction, endFraction))
    }
    set {
      shape.animatableData = newValue[].0
      (startFraction, endFraction) = newValue[].1[]
    }
  }
}

public struct OffsetShape<Content>: Shape where Content: Shape {
  public var shape: Content
  public var offset: CGSize

  public init(shape: Content, offset: CGSize) {
    self.shape = shape
    self.offset = offset
  }

  public func path(in rect: CGRect) -> Path {
    shape
      .path(in: rect)
      .offsetBy(dx: offset.width, dy: offset.height)
  }

  public typealias AnimatableData = AnimatablePair<Content.AnimatableData, CGSize.AnimatableData>
  public var animatableData: AnimatableData {
    get {
      .init(shape.animatableData, offset.animatableData)
    }
    set {
      (shape.animatableData, offset.animatableData) = newValue[]
    }
  }
}

extension OffsetShape: InsettableShape where Content: InsettableShape {
  public func inset(by amount: CGFloat) -> OffsetShape<Content.InsetShape> {
    shape
      .inset(by: amount)
      .offset(offset)
  }
}

public struct ScaledShape<Content>: Shape where Content: Shape {
  public var shape: Content
  public var scale: CGSize
  public var anchor: UnitPoint

  public init(shape: Content, scale: CGSize, anchor: UnitPoint = .center) {
    self.shape = shape
    self.scale = scale
    self.anchor = anchor
  }

  public func path(in rect: CGRect) -> Path {
    shape
      .path(in: rect)
      .applying(.init(scaleX: scale.width, y: scale.height))
  }

  public typealias AnimatableData = AnimatablePair<
    Content.AnimatableData,
    AnimatablePair<CGSize.AnimatableData, UnitPoint.AnimatableData>
  >
  public var animatableData: AnimatableData {
    get {
      .init(shape.animatableData, .init(scale.animatableData, anchor.animatableData))
    }
    set {
      shape.animatableData = newValue[].0
      (scale.animatableData, anchor.animatableData) = newValue[].1[]
    }
  }
}

public struct RotatedShape<Content>: Shape where Content: Shape {
  public var shape: Content
  public var angle: Angle
  public var anchor: UnitPoint

  public init(shape: Content, angle: Angle, anchor: UnitPoint = .center) {
    self.shape = shape
    self.angle = angle
    self.anchor = anchor
  }

  public func path(in rect: CGRect) -> Path {
    shape
      .path(in: rect)
      .applying(.init(rotationAngle: CGFloat(angle.radians)))
  }

  public typealias AnimatableData = AnimatablePair<
    Content.AnimatableData,
    AnimatablePair<Angle.AnimatableData, UnitPoint.AnimatableData>
  >
  public var animatableData: AnimatableData {
    get {
      .init(shape.animatableData, .init(angle.animatableData, anchor.animatableData))
    }
    set {
      shape.animatableData = newValue[].0
      (angle.animatableData, anchor.animatableData) = newValue[].1[]
    }
  }
}

extension RotatedShape: InsettableShape where Content: InsettableShape {
  public func inset(by amount: CGFloat) -> RotatedShape<Content.InsetShape> {
    shape.inset(by: amount).rotation(angle, anchor: anchor)
  }
}

public struct TransformedShape<Content>: Shape where Content: Shape {
  public var shape: Content
  public var transform: CGAffineTransform

  public init(shape: Content, transform: CGAffineTransform) {
    self.shape = shape
    self.transform = transform
  }

  public func path(in rect: CGRect) -> Path {
    shape
      .path(in: rect)
      .applying(transform)
  }

  public var animatableData: Content.AnimatableData {
    get { shape.animatableData }
    set { shape.animatableData = newValue }
  }
}

public struct _SizedShape<S>: Shape where S: Shape {
  public var shape: S
  public var size: CGSize

  public init(shape: S, size: CGSize) {
    self.shape = shape
    self.size = size
  }

  // TODO: Figure out how to set the size of a Path
  public func path(in rect: CGRect) -> Path {
    shape
      .path(in: rect)
  }

  public typealias AnimatableData = AnimatablePair<S.AnimatableData, CGSize.AnimatableData>
  public var animatableData: AnimatableData {
    get {
      .init(shape.animatableData, size.animatableData)
    }
    set {
      (shape.animatableData, size.animatableData) = newValue[]
    }
  }
}

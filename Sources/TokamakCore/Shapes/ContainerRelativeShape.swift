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

import Foundation

public struct ContainerRelativeShape: Shape, EnvironmentReader {
  var containerShape: (CGRect, GeometryProxy) -> Path? = { _, _ in nil }

  public func path(in rect: CGRect) -> Path {
    containerShape(rect, GeometryProxy(size: rect.size)) ?? Rectangle().path(in: rect)
  }

  public init() {}

  public mutating func setContent(from values: EnvironmentValues) {
    containerShape = values._containerShape
  }
}

extension ContainerRelativeShape: InsettableShape {
  @inlinable
  public func inset(by amount: CGFloat) -> some InsettableShape {
    _Inset(amount: amount)
  }

  @usableFromInline
  @frozen
  internal struct _Inset: InsettableShape, DynamicProperty {
    @usableFromInline
    internal var amount: CGFloat
    @inlinable
    internal init(amount: CGFloat) {
      self.amount = amount
    }

    @usableFromInline
    internal func path(in rect: CGRect) -> Path {
      // FIXME: Inset the container shape.
      Rectangle().path(in: rect)
    }

    @inlinable
    internal func inset(by amount: CGFloat) -> ContainerRelativeShape._Inset {
      var copy = self
      copy.amount += amount
      return copy
    }
  }
}

private extension EnvironmentValues {
  enum ContainerShapeKey: EnvironmentKey {
    static let defaultValue: (CGRect, GeometryProxy) -> Path? = { _, _ in nil }
  }

  var _containerShape: (CGRect, GeometryProxy) -> Path? {
    get {
      self[ContainerShapeKey.self]
    }
    set {
      self[ContainerShapeKey.self] = newValue
    }
  }
}

@frozen
public struct _ContainerShapeModifier<Shape>: ViewModifier where Shape: InsettableShape {
  public var shape: Shape
  @inlinable
  public init(shape: Shape) { self.shape = shape }

  public func body(content: Content) -> some View {
    _ContainerShapeView(content: content, shape: shape)
  }

  public struct _ContainerShapeView: View {
    public let content: Content
    public let shape: Shape

    public var body: some View {
      content
        .environment(\._containerShape) { rect, proxy in
          shape
            .inset(by: proxy.size.width) // TODO: Calculate the offset using content's geometry
            .path(in: rect)
        }
    }
  }
}

public extension View {
  @inlinable
  func containerShape<T>(_ shape: T) -> some View where T: InsettableShape {
    modifier(_ContainerShapeModifier(shape: shape))
  }
}

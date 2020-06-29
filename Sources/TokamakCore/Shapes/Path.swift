// Copyright 2020 Tokamak contributors
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

/// The outline of a 2D shape.
public struct Path: Equatable, LosslessStringConvertible {
  public var description: String {
    """
    \(storage)
    \(elements)
    \(transform)
    """
  }

  public enum Storage: Equatable {
    case empty
    case rect(CGRect)
    case ellipse(CGRect)
    indirect case roundedRect(FixedRoundedRect)
    indirect case stroked(StrokedPath)
    indirect case trimmed(TrimmedPath)
//    case path(PathBox)
  }

  public enum Element: Equatable {
    case move(to: CGPoint)
    case line(to: CGPoint)
    case quadCurve(to: CGPoint, control: CGPoint)
    case curve(to: CGPoint, control1: CGPoint, control2: CGPoint)
    case closeSubpath
  }

  public var storage: Storage
  public var elements: [Element] = []
  public var transform: CGAffineTransform = .identity

  public struct _SubPath: Equatable {
    let path: Path
    let transform: CGAffineTransform
  }

  public var subpaths: [_SubPath] = []

  public init() {
    storage = .empty
  }

  init(storage: Storage) {
    self.storage = storage
  }

  public init(_ rect: CGRect) {
    storage = .rect(rect)
  }

  public init(roundedRect rect: CGRect,
              cornerSize: CGSize,
              style: RoundedCornerStyle = .circular) {
    storage = .roundedRect(FixedRoundedRect(rect: rect,
                                            cornerRadius: cornerSize.width,
                                            style: style))
    // FIXME: This currently doesn't support an actualy CGSize. I'm not sure how that works or what it does.
  }

  public init(roundedRect rect: CGRect,
              cornerRadius: CGFloat,
              style: RoundedCornerStyle = .circular) {
    storage = .roundedRect(FixedRoundedRect(rect: rect,
                                            cornerRadius: cornerRadius,
                                            style: style))
  }

  public init(ellipseIn rect: CGRect) {
    storage = .ellipse(rect)
  }

  public init(_ callback: (inout Self) -> ()) {
    var base = Self()
    callback(&base)
    self = base
  }

  public init?(_ string: String) {
    // Somehow make this from a string?
    self.init()
  }

  // We don't have CGPath
  //  public var cgPath: CGPath {
  //
  //  }
  public var isEmpty: Bool {
    storage == .empty
  }

  public var boundingRect: CGRect {
    switch storage {
    case .empty: return .zero
    case let .rect(rect): return rect
    case let .ellipse(rect): return rect
    case let .roundedRect(fixedRoundedRect): return fixedRoundedRect.rect
    case let .stroked(strokedPath): return strokedPath.path.boundingRect
    case let .trimmed(trimmedPath): return trimmedPath.path.boundingRect
    }
  }

  public func contains(_ p: CGPoint, eoFill: Bool = false) -> Bool {
    false
  }

  public func forEach(_ body: (Element) -> ()) {
    elements.forEach { body($0) }
  }

  public func strokedPath(_ style: StrokeStyle) -> Self {
    Self(storage: .stroked(StrokedPath(path: self, style: style)))
  }

  public func trimmedPath(from: CGFloat, to: CGFloat) -> Self {
    Self(storage: .trimmed(TrimmedPath(path: self, from: from, to: to)))
  }

  //  In SwiftUI, but we don't have CGPath...
  //  public init(_ path: CGPath)
  //  public init(_ path: CGMutablePath)
}

public struct FixedRoundedRect: Equatable {
  public let rect: CGRect
  public let cornerRadius: CGFloat
  public let style: RoundedCornerStyle
}

public struct StrokedPath: Equatable {
  public let path: Path
  public let style: StrokeStyle

  public init(path: Path, style: StrokeStyle) {
    self.path = path
    self.style = style
  }
}

public struct TrimmedPath: Equatable {
  public let path: Path
  public let from: CGFloat
  public let to: CGFloat

  public init(path: Path, from: CGFloat, to: CGFloat) {
    self.path = path
    self.from = from
    self.to = to
  }
}

public struct StrokeStyle: Equatable {
  public var lineWidth: CGFloat
  public var lineCap: CGLineCap
  public var lineJoin: CGLineJoin
  public var miterLimit: CGFloat
  public var dash: [CGFloat]
  public var dashPhase: CGFloat

  public init(lineWidth: CGFloat = 1,
              lineCap: CGLineCap = .butt,
              lineJoin: CGLineJoin = .miter,
              miterLimit: CGFloat = 10,
              dash: [CGFloat] = [CGFloat](),
              dashPhase: CGFloat = 0) {
    self.lineWidth = lineWidth
    self.lineCap = lineCap
    self.lineJoin = lineJoin
    self.miterLimit = miterLimit
    self.dash = dash
    self.dashPhase = dashPhase
  }
}

public enum RoundedCornerStyle: Hashable, Equatable {
  case circular
  case continuous
}

extension Path {
  public mutating func move(to p: CGPoint) {
    elements.append(.move(to: p))
  }

  public mutating func addLine(to p: CGPoint) {
    elements.append(.line(to: p))
  }

  public mutating func addQuadCurve(to p: CGPoint, control cp: CGPoint) {
    elements.append(.quadCurve(to: p, control: cp))
  }

  public mutating func addCurve(to p: CGPoint, control1 cp1: CGPoint, control2 cp2: CGPoint) {
    elements.append(.curve(to: p, control1: cp1, control2: cp2))
  }

  public mutating func closeSubpath() {
    elements.append(.closeSubpath)
  }

  public mutating func addRect(_ rect: CGRect, transform: CGAffineTransform = .identity) {
    subpaths.append(.init(path: .init(rect), transform: transform))
  }

  public mutating func addRoundedRect(in rect: CGRect,
                                      cornerSize: CGSize,
                                      style: RoundedCornerStyle = .circular,
                                      transform: CGAffineTransform = .identity) {
    subpaths.append(.init(path: .init(roundedRect: rect,
                                      cornerSize: cornerSize,
                                      style: style),
                          transform: transform))
  }

  public mutating func addEllipse(in rect: CGRect, transform: CGAffineTransform = .identity) {
    subpaths.append(.init(path: .init(ellipseIn: rect), transform: transform))
  }

  public mutating func addRects(_ rects: [CGRect], transform: CGAffineTransform = .identity) {
    rects.forEach { addRect($0) }
  }

  public mutating func addLines(_ lines: [CGPoint]) {
    lines.forEach { addLine(to: $0) }
  }

  public mutating func addRelativeArc(center: CGPoint,
                                      radius: CGFloat,
                                      startAngle: Angle,
                                      delta: Angle,
                                      transform: CGAffineTransform = .identity) {
    // I don't know how to do this without sin/cos
  }

  public mutating func addArc(center: CGPoint,
                              radius: CGFloat,
                              startAngle: Angle,
                              endAngle: Angle,
                              clockwise: Bool,
                              transform: CGAffineTransform = .identity) {
    // I don't know how to do this without sin/cos
  }

  public mutating func addArc(tangent1End p1: CGPoint,
                              tangent2End p2: CGPoint,
                              radius: CGFloat,
                              transform: CGAffineTransform = .identity) {
    // I don't know how to do this without sin/cos
  }

  public mutating func addPath(_ path: Path, transform: CGAffineTransform = .identity) {
    subpaths.append(.init(path: path, transform: transform))
  }

  public var currentPoint: CGPoint? {
    nil
  }

  public func applying(_ transform: CGAffineTransform) -> Path {
    var path = self
    path.transform = transform
    return path
  }

  public func offsetBy(dx: CGFloat, dy: CGFloat) -> Path {
    applying(transform.translatedBy(x: dx, y: dy))
  }
}

extension Path: Shape {
  public func path(in rect: CGRect) -> Path {
    self
  }
}

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

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif os(WASI)
import WASILibc
#endif

/// The outline of a 2D shape.
public struct Path: Equatable, LosslessStringConvertible {
  public class PathBox: Equatable {
    var elements: [Element] = []
    public static func == (lhs: Path.PathBox, rhs: Path.PathBox) -> Bool {
      return lhs.elements == rhs.elements
    }
    init() {
    }
    init(elements: [Element]) {
      self.elements = elements
    }
  }
  public var description: String {
    var pathString = [String]()
    for element in elements {
      switch element {
      case let .move(to: pos):
        pathString.append("\(pos.x) \(pos.y) m")
      case let .line(to: pos):
        pathString.append("\(pos.x) \(pos.y) l")
      case let .curve(to: pos, control1: c1, control2: c2):
        pathString.append("\(c1.x) \(c1.y) \(c2.x) \(c2.y) \(pos.x) \(pos.y) c")
      case let .quadCurve(to: pos, control: c):
        pathString.append("\(c.x) \(c.y) \(pos.x) \(pos.y) q")
      case .closeSubpath:
        pathString.append("h")
      }
    }
    return pathString.joined(separator: " ")
  }

  public enum Storage: Equatable {
    case empty
    case rect(CGRect)
    case ellipse(CGRect)
    case roundedRect(FixedRoundedRect)
    indirect case stroked(StrokedPath)
    indirect case trimmed(TrimmedPath)
    case path(PathBox)

    var elements: [Element] {
      switch self {
      case .empty:
        return []
      case .rect(let rect):
        return [
          .move(to: rect.origin),
          .line(to: CGPoint(x: rect.size.width, y: 0).offset(by: rect.origin)),
          .line(to: CGPoint(x: rect.size.width, y: rect.size.height).offset(by: rect.origin)),
          .line(to: CGPoint(x: 0, y: rect.size.height).offset(by: rect.origin)),
          .closeSubpath
        ]

      case .ellipse(let rect):
        // TODO: Figure out actual algorithm - for now I just added a rounded rect with corner size
        // of a quater of the rect
        let cornerSize = CGSize(width: rect.size.width, height: rect.size.height)
        return [
          .move(to: CGPoint(x: rect.size.width, y: rect.size.height / 2).offset(by: rect.origin)),
          .line(
            to: CGPoint(x: rect.size.width, y: rect.size.height - cornerSize.height)
              .offset(by: rect.origin)
          ),
          .quadCurve(
            to: CGPoint(x: rect.size.width - cornerSize.width, y: rect.size.height)
              .offset(by: rect.origin),
            control: CGPoint(x: rect.size.width, y: rect.size.height)
              .offset(by: rect.origin)
          ),
          .line(to: CGPoint(x: cornerSize.width, y: rect.size.height).offset(by: rect.origin)),
          .quadCurve(
            to: CGPoint(x: 0, y: rect.size.height - cornerSize.height)
              .offset(by: rect.origin),
            control: CGPoint(x: 0, y: rect.size.height)
              .offset(by: rect.origin)
          ),
          .line(to: CGPoint(x: 0, y: cornerSize.height).offset(by: rect.origin)),
          .quadCurve(
            to: CGPoint(x: cornerSize.width, y: 0)
              .offset(by: rect.origin),
            control: CGPoint.zero
              .offset(by: rect.origin)
          ),
          .line(to: CGPoint(x: rect.size.width - cornerSize.width, y: 0).offset(by: rect.origin)),
          .quadCurve(
            to: CGPoint(x: rect.size.width, y: cornerSize.height)
              .offset(by: rect.origin),
            control: CGPoint(x: rect.size.width, y: 0)
              .offset(by: rect.origin)
          ),
          .closeSubpath
        ]

      case .roundedRect(let roundedRect):
        // TODO: Check that zero is the default value in SwiftUI
        let cornerSize = roundedRect.cornerSize ?? .zero
        let cornerStyle = roundedRect.style
        let rect = roundedRect.rect
        switch cornerStyle {
        case .continuous:
          return [
            .move(to: CGPoint(x: rect.size.width, y: rect.size.height / 2).offset(by: rect.origin)),
            .line(
              to: CGPoint(x: rect.size.width, y: rect.size.height - cornerSize.height)
                .offset(by: rect.origin)
            ),
            .quadCurve(
              to: CGPoint(x: rect.size.width - cornerSize.width, y: rect.size.height)
                .offset(by: rect.origin),
              control: CGPoint(x: rect.size.width, y: rect.size.height)
                .offset(by: rect.origin)
            ),
            .line(to: CGPoint(x: cornerSize.width, y: rect.size.height).offset(by: rect.origin)),
            .quadCurve(
              to: CGPoint(x: 0, y: rect.size.height - cornerSize.height)
                .offset(by: rect.origin),
              control: CGPoint(x: 0, y: rect.size.height)
                .offset(by: rect.origin)
            ),
            .line(to: CGPoint(x: 0, y: cornerSize.height).offset(by: rect.origin)),
            .quadCurve(
              to: CGPoint(x: cornerSize.width, y: 0)
                .offset(by: rect.origin),
              control: CGPoint.zero
                .offset(by: rect.origin)
            ),
            .line(to: CGPoint(x: rect.size.width - cornerSize.width, y: 0).offset(by: rect.origin)),
            .quadCurve(
              to: CGPoint(x: rect.size.width, y: cornerSize.height)
                .offset(by: rect.origin),
              control: CGPoint(x: rect.size.width, y: 0)
                .offset(by: rect.origin)
            ),
            .closeSubpath
          ]

        case .circular:
          // TODO: This currently only supports circular corners and not ellipsoidal...
          // This could be implemented by transforming the elements returned by
          // the getArc calls.
          return
            [
              [
                .move(to: CGPoint(x: rect.size.width, y: rect.size.height / 2).offset(by: rect.origin)),
                .line(
                  to: CGPoint(x: rect.size.width, y: rect.size.height - cornerSize.height)
                    .offset(by: rect.origin)
                )
              ],
              getArc(center: CGPoint(x: rect.size.width - cornerSize.width,
                                     y: rect.size.height - cornerSize.height)
                      .offset(by: rect.origin),
                     radius: cornerSize.width,
                     startAngle: Angle(radians: 0),
                     endAngle: Angle(radians: Double.pi / 2),
                     clockwise: false),
              [.line(to: CGPoint(x: cornerSize.width, y: rect.size.height).offset(by: rect.origin))],
              getArc(center: CGPoint(x: cornerSize.width,
                                     y: rect.size.height - cornerSize.height)
                      .offset(by: rect.origin),
                     radius: cornerSize.width,
                     startAngle: Angle(radians: Double.pi / 2),
                     endAngle: Angle(radians: Double.pi),
                     clockwise: false),
              [.line(to: CGPoint(x: 0, y: cornerSize.height).offset(by: rect.origin))],
              getArc(center: CGPoint(x: cornerSize.width,
                                     y: cornerSize.height)
                      .offset(by: rect.origin),
                     radius: cornerSize.width,
                     startAngle: Angle(radians: Double.pi),
                     endAngle: Angle(radians: 3 * Double.pi / 2),
                     clockwise: false),
              [.line(to: CGPoint(x: rect.size.width - cornerSize.width, y: 0).offset(by: rect.origin))],
              getArc(center: CGPoint(x: rect.size.width - cornerSize.width,
                                     y: cornerSize.height)
                      .offset(by: rect.origin),
                     radius: cornerSize.width,
                     startAngle: Angle(radians: 3 * Double.pi / 2),
                     endAngle: Angle(radians: 2 * Double.pi),
                     clockwise: false),
              [.closeSubpath]
            ].flatMap({ $0 })
        }

      case .stroked(let stroked):
        // TODO: This is not actually how stroking is implemented
        return stroked.path.storage.elements

      case .trimmed(let trimmed):
        // TODO: This is not actually how stroking is implemented
        return trimmed.path.storage.elements

      case .path(let box):
        return box.elements
      }
    }
  }

  public enum Element: Equatable {
    case move(to: CGPoint)
    case line(to: CGPoint)
    case quadCurve(to: CGPoint, control: CGPoint)
    case curve(to: CGPoint, control1: CGPoint, control2: CGPoint)
    case closeSubpath
  }

  public var storage: Storage
  public let sizing: _Sizing

  public var elements: [Element] { storage.elements }

  public init() {
    storage = .empty
    sizing = .fixed
  }

  init(storage: Storage, sizing: _Sizing = .fixed) {
    self.storage = storage
    self.sizing = sizing
  }

  public init(_ rect: CGRect) {
    self.init(storage: .rect(rect))
  }

  public init(roundedRect rect: CGRect, cornerSize: CGSize, style: RoundedCornerStyle = .circular) {
    self.init(
      storage: .roundedRect(FixedRoundedRect(rect: rect, cornerSize: cornerSize, style: style))
    )
  }

  public init(
    roundedRect rect: CGRect,
    cornerRadius: CGFloat,
    style: RoundedCornerStyle = .circular
  ) {
    self.init(
      storage: .roundedRect(FixedRoundedRect(
        rect: rect,
        cornerSize: CGSize(width: cornerRadius, height: cornerRadius),
        style: style
      ))
    )
  }

  public init(ellipseIn rect: CGRect) {
    self.init(storage: .ellipse(rect))
  }

  public init(_ callback: (inout Self) -> ()) {
    var base = Self()
    callback(&base)
    self = base
  }

  public init?(_ string: String) {
    // FIXME: Somehow make this from a string?
    self.init()
  }

  // FIXME: We don't have CGPath
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
      // XXX TODO
    case let .path(pathBox): return .zero
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

  //  FIXME: In SwiftUI, but we don't have CGPath...
  //  public init(_ path: CGPath)
  //  public init(_ path: CGMutablePath)
}

public enum RoundedCornerStyle: Hashable, Equatable {
  case circular
  case continuous
}

public extension Path {

  private mutating func append(_ other: Storage, transform: CGAffineTransform = .identity) {
    guard other != .empty else { return }

    // If self.storage is empty, replace with other storage.
    // Otherwise append elements to current storage.
    switch (storage, transform.isIdentity) {
    case (.empty, true):
      storage = other

    default:
      append(other.elements, transform: transform)
    }
  }

  private mutating func append(_ elements: [Element], transform: CGAffineTransform = .identity) {
    guard !elements.isEmpty else { return }

    let elements_: [Element]
    if transform.isIdentity {
      elements_ = elements
    } else {
      elements_ = elements.map { transform.transform(element: $0) }
    }

    switch storage {
    case let .path(pathBox):
      pathBox.elements.append(contentsOf: elements_)

    default:
      storage = .path(PathBox(elements: storage.elements + elements_))
    }
  }

  mutating func move(to p: CGPoint) {
    append([.move(to: p)])
  }

  mutating func addLine(to p: CGPoint) {
    append([.line(to: p)])
  }

  mutating func addQuadCurve(to p: CGPoint, control cp: CGPoint) {
    append([.quadCurve(to: p, control: cp)])
  }

  mutating func addCurve(to p: CGPoint, control1 cp1: CGPoint, control2 cp2: CGPoint) {
    append([.curve(to: p, control1: cp1, control2: cp2)])
  }

  mutating func closeSubpath() {
    append([.closeSubpath])
  }

  mutating func addRect(_ rect: CGRect, transform: CGAffineTransform = .identity) {
    append(.rect(rect), transform: transform)
  }

  mutating func addRoundedRect(
    in rect: CGRect,
    cornerSize: CGSize,
    style: RoundedCornerStyle = .circular,
    transform: CGAffineTransform = .identity
  ) {
    append(.roundedRect(FixedRoundedRect(rect: rect, cornerSize: cornerSize, style: style)), transform: transform)
  }

  mutating func addEllipse(in rect: CGRect, transform: CGAffineTransform = .identity) {
    append(.ellipse(rect), transform: transform)
  }

  mutating func addRects(_ rects: [CGRect], transform: CGAffineTransform = .identity) {
    rects.forEach { addRect($0, transform: transform) }
  }

  mutating func addLines(_ lines: [CGPoint]) {
    lines.forEach { addLine(to: $0) }
  }

  mutating func addRelativeArc(
    center: CGPoint,
    radius: CGFloat,
    startAngle: Angle,
    delta: Angle,
    transform: CGAffineTransform = .identity
  ) {
    addArc(
      center: center,
      radius: radius,
      startAngle: startAngle,
      endAngle: startAngle + delta,
      clockwise: false,
      transform: transform
    )
  }

  // There's a great article on bezier curves here:
  // https://pomax.github.io/bezierinfo
  // FIXME: Handle negative delta
  mutating func addArc(
    center: CGPoint,
    radius: CGFloat,
    startAngle: Angle,
    endAngle: Angle,
    clockwise: Bool,
    transform: CGAffineTransform = .identity
  ) {
    let arc = getArc(
      center: center,
      radius: radius,
      startAngle: endAngle,
      endAngle: endAngle + (.radians(.pi * 2) - endAngle) + startAngle,
      clockwise: false
    )
    self.append(arc, transform: transform)
  }

  // FIXME: How does this arc method work?
  mutating func addArc(
    tangent1End p1: CGPoint,
    tangent2End p2: CGPoint,
    radius: CGFloat,
    transform: CGAffineTransform = .identity
  ) {}

  mutating func addPath(_ path: Path, transform: CGAffineTransform = .identity) {
    // TODO: handle transform
    append(path.storage, transform: transform)
  }

  var currentPoint: CGPoint? {
    switch elements.last {
    case let .move(to: point): return point
    case let .line(to: point): return point
    case let .curve(to: point, control1: _, control2: _): return point
    case let .quadCurve(to: point, control: _): return point
    default: return nil
    }
  }

  func applying(_ transform: CGAffineTransform) -> Path {
    guard transform != .identity else { return self }
    let elements = self.elements.map { transform.transform(element: $0) }
    let box = PathBox(elements: elements)
    return Path(storage: .path(box), sizing: .fixed)
  }

  func offsetBy(dx: CGFloat, dy: CGFloat) -> Path {
    applying(.init(translationX: dx, y: dy))
  }
}

extension Path: Shape {
  public func path(in rect: CGRect) -> Path {
    self
  }
}

extension CGAffineTransform {
  public func transform(element: Path.Element) -> Path.Element {
    switch element {
    case let .move(to: p):
      return .move(to: self.transform(point: p))

    case let .line(to: p):
      return .line(to: self.transform(point: p))

    case let .curve(to: p, control1: c1, control2: c2):
      return .curve(to: self.transform(point: p), control1: self.transform(point: c1), control2: self.transform(point: c2))

    case let .quadCurve(to: p, control: c):
      return .quadCurve(to: self.transform(point: p), control: self.transform(point: c))

    case .closeSubpath:
      return element
    }
  }
}

private func getArc(
  center: CGPoint,
  radius: CGFloat,
  startAngle: Angle,
  endAngle: Angle,
  clockwise: Bool
) -> [Path.Element] {
  if clockwise {
    return getArc(
      center: center,
      radius: radius,
      startAngle: endAngle,
      endAngle: endAngle + (.radians(.pi * 2) - endAngle) + startAngle,
      clockwise: false
    )
  } else {
    let angle = abs(startAngle.radians - endAngle.radians)
    if angle > .pi / 2 {
      // Split the angle into 90º chunks
      let chunk1 = Angle.radians(startAngle.radians + (.pi / 2))
      return getArc(
        center: center,
        radius: radius,
        startAngle: startAngle,
        endAngle: chunk1,
        clockwise: clockwise
      ) +
      getArc(
        center: center,
        radius: radius,
        startAngle: chunk1,
        endAngle: endAngle,
        clockwise: clockwise
      )
    } else {
      let endPoint = CGPoint(
        x: (radius * cos(angle)) + center.x,
        y: (radius * sin(angle)) + center.y
      )
      let l = (4 / 3) * tan(angle / 4)
      let c1 = CGPoint(x: radius + center.x, y: (l * radius) + center.y)
      let c2 = CGPoint(
        x: ((cos(angle) + l * sin(angle)) * radius) + center.x,
        y: ((sin(angle) - l * cos(angle)) * radius) + center.y
      )

      return [
        .curve(
          to: endPoint.rotate(startAngle, around: center),
          control1: c1.rotate(startAngle, around: center),
          control2: c2.rotate(startAngle, around: center)
        )
      ]
    }
  }
}

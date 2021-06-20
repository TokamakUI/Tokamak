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
//
//  Created by Max Desiatov on 20/06/2021.
//

import Foundation

public extension Path.Storage {
  var elements: [Path.Element] {
    switch self {
    case .empty:
      return []
    case let .rect(rect):
      return [
        .move(to: rect.origin),
        .line(to: CGPoint(x: rect.size.width, y: 0).offset(by: rect.origin)),
        .line(to: CGPoint(x: rect.size.width, y: rect.size.height).offset(by: rect.origin)),
        .line(to: CGPoint(x: 0, y: rect.size.height).offset(by: rect.origin)),
        .closeSubpath,
      ]

    case let .ellipse(rect):
      // Scale down from a circle of max(width, height) in order to limit
      // precision loss. Scaling up from a unit circle also looked alright,
      // but scaling down is likely a bit better.
      let size = max(rect.size.width, rect.size.height)
      guard size > 0 else { return [] }
      let transform: CGAffineTransform
      if rect.size.width > rect.size.height {
        transform = CGAffineTransform(
          scaleX: 1,
          y: rect.size.height / rect.size.width
        )
      } else if rect.size.height > rect.size.width {
        transform = CGAffineTransform(
          scaleX: rect.size.width / rect.size.height,
          y: 1
        )
      } else {
        transform = .identity
      }
      let elements = [
        [.move(to: CGPoint(x: size, y: size / 2))],
        getArc(
          center: CGPoint(
            x: size / 2,
            y: size / 2
          ),
          radius: size / 2,
          startAngle: Angle(radians: 0),
          endAngle: Angle(radians: 2 * Double.pi),
          clockwise: false
        ),
        [.closeSubpath],
      ].flatMap { $0 }
      return elements.map {
        transform
          .translatedBy(x: rect.origin.x, y: rect.origin.y)
          .transform(element: $0)
      }

    case let .roundedRect(roundedRect):
      // A cornerSize of nil means that we are drawing a Capsule
      // In other words the corner size should be half of the min
      // of the size and width
      let rect = roundedRect.rect
      let cornerSize = roundedRect.cornerSize ??
        CGSize(
          width: min(rect.size.width, rect.size.height) / 2,
          height: min(rect.size.width, rect.size.height) / 2
        )
      let cornerStyle = roundedRect.style
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
          .closeSubpath,
        ]

      case .circular:
        // TODO: This currently only supports circular corners and not ellipsoidal...
        // This could be implemented by transforming the elements returned by
        // the getArc calls.
        return
          [
            [
              .move(
                to: CGPoint(x: rect.size.width, y: rect.size.height / 2)
                  .offset(by: rect.origin)
              ),
              .line(
                to: CGPoint(x: rect.size.width, y: rect.size.height - cornerSize.height)
                  .offset(by: rect.origin)
              ),
            ],
            getArc(
              center: CGPoint(
                x: rect.size.width - cornerSize.width,
                y: rect.size.height - cornerSize.height
              )
              .offset(by: rect.origin),
              radius: cornerSize.width,
              startAngle: Angle(radians: 0),
              endAngle: Angle(radians: Double.pi / 2),
              clockwise: false
            ),
            [.line(
              to: CGPoint(x: cornerSize.width, y: rect.size.height)
                .offset(by: rect.origin)
            )],
            getArc(
              center: CGPoint(
                x: cornerSize.width,
                y: rect.size.height - cornerSize.height
              )
              .offset(by: rect.origin),
              radius: cornerSize.width,
              startAngle: Angle(radians: Double.pi / 2),
              endAngle: Angle(radians: Double.pi),
              clockwise: false
            ),
            [.line(
              to: CGPoint(x: 0, y: cornerSize.height)
                .offset(by: rect.origin)
            )],
            getArc(
              center: CGPoint(
                x: cornerSize.width,
                y: cornerSize.height
              )
              .offset(by: rect.origin),
              radius: cornerSize.width,
              startAngle: Angle(radians: Double.pi),
              endAngle: Angle(radians: 3 * Double.pi / 2),
              clockwise: false
            ),
            [.line(
              to: CGPoint(x: rect.size.width - cornerSize.width, y: 0)
                .offset(by: rect.origin)
            )],
            getArc(
              center: CGPoint(
                x: rect.size.width - cornerSize.width,
                y: cornerSize.height
              )
              .offset(by: rect.origin),
              radius: cornerSize.width,
              startAngle: Angle(radians: 3 * Double.pi / 2),
              endAngle: Angle(radians: 2 * Double.pi),
              clockwise: false
            ),
            [.closeSubpath],
          ].flatMap { $0 }
      }

    case let .stroked(stroked):
      // TODO: This is not actually how stroking is implemented
      return stroked.path.storage.elements

    case let .trimmed(trimmed):
      // TODO: This is not actually how trimmingis implemented
      return trimmed.path.storage.elements

    case let .path(box):
      return box.elements
    }
  }
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
      storage = .path(_PathBox(elements: storage.elements + elements_))
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
    append(
      .roundedRect(FixedRoundedRect(rect: rect, cornerSize: cornerSize, style: style)),
      transform: transform
    )
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
    append(arc, transform: transform)
  }

  // FIXME: How does this arc method work?
  mutating func addArc(
    tangent1End p1: CGPoint,
    tangent2End p2: CGPoint,
    radius: CGFloat,
    transform: CGAffineTransform = .identity
  ) {}

  mutating func addPath(_ path: Path, transform: CGAffineTransform = .identity) {
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
    let box = _PathBox(elements: elements)
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

public extension CGAffineTransform {
  func transform(element: Path.Element) -> Path.Element {
    switch element {
    case let .move(to: p):
      return .move(to: transform(point: p))

    case let .line(to: p):
      return .line(to: transform(point: p))

    case let .curve(to: p, control1: c1, control2: c2):
      return .curve(
        to: transform(point: p),
        control1: transform(point: c1),
        control2: transform(point: c2)
      )

    case let .quadCurve(to: p, control: c):
      return .quadCurve(to: transform(point: p), control: transform(point: c))

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
      let angle = CGFloat(angle)
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
        ),
      ]
    }
  }
}

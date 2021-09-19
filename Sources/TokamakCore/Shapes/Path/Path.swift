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

/// The outline of a 2D shape.
public struct Path: Equatable, LosslessStringConvertible {
  public class _PathBox: Equatable {
    public var elements: [Element] = []
    public static func == (lhs: Path._PathBox, rhs: Path._PathBox) -> Bool {
      lhs.elements == rhs.elements
    }

    init() {}

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
    indirect case roundedRect(FixedRoundedRect)
    indirect case stroked(StrokedPath)
    indirect case trimmed(TrimmedPath)
    case path(_PathBox)
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
    case let .path(pathBox):
      // Note: Copied from TokamakStaticHTML/Shapes/Path.swift
      // Should the control points be included in the positions array?
      let positions = pathBox.elements.compactMap { elem -> CGPoint? in
        switch elem {
        case let .move(to: pos): return pos
        case let .line(to: pos): return pos
        case let .curve(to: pos, control1: _, control2: _): return pos
        case let .quadCurve(to: pos, control: _): return pos
        case .closeSubpath: return nil
        }
      }
      let xPos = positions.map(\.x).sorted(by: <)
      let minX = xPos.first ?? 0
      let maxX = xPos.last ?? 0
      let yPos = positions.map(\.y).sorted(by: <)
      let minY = yPos.first ?? 0
      let maxY = yPos.last ?? 0

      return CGRect(
        origin: CGPoint(x: minX, y: minY),
        size: CGSize(width: maxX - minX, height: maxY - minY)
      )
    }
  }

  public func contains(_ p: CGPoint, eoFill: Bool = false) -> Bool {
    false
  }

  public func forEach(_ body: (Element) -> ()) {
    elements.forEach { body($0) }
  }

  public func strokedPath(_ style: StrokeStyle) -> Self {
    Self(storage: .stroked(StrokedPath(path: self, style: style)), sizing: sizing)
  }

  public func trimmedPath(from: CGFloat, to: CGFloat) -> Self {
    Self(storage: .trimmed(TrimmedPath(path: self, from: from, to: to)), sizing: sizing)
  }

  //  FIXME: In SwiftUI, but we don't have CGPath...
  //  public init(_ path: CGPath)
  //  public init(_ path: CGMutablePath)
}

public enum RoundedCornerStyle: Hashable, Equatable {
  case circular
  case continuous
}

//
//  Frame.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 29/12/2018.
//

import Tokamak
import UIKit

extension CGPoint {
  public init(_ point: Point) {
    self.init(x: point.x, y: point.y)
  }
}

extension CGSize {
  public init(_ size: Size) {
    self.init(width: size.width, height: size.height)
  }
}

extension CGRect {
  public init(_ rectangle: Rectangle) {
    self.init(origin: CGPoint(rectangle.origin), size: CGSize(rectangle.size))
  }
}

extension Point {
  public init(_ point: CGPoint) {
    self.init(x: Double(point.x), y: Double(point.y))
  }
}

extension Size {
  public init(_ size: CGSize) {
    self.init(width: Double(size.width), height: Double(size.height))
  }
}

extension Rectangle {
  public init(_ rect: CGRect) {
    self.init(Point(rect.origin), Size(rect.size))
  }
}

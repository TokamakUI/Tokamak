//
//  Frame.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 29/12/2018.
//

import Gluon
import UIKit

extension CGPoint {
  init(_ point: Point) {
    self.init(x: point.x, y: point.y)
  }
}

extension CGSize {
  init(_ size: Size) {
    self.init(width: size.width, height: size.height)
  }
}

extension CGRect {
  init(_ frame: Frame) {
    self.init(origin: CGPoint(frame.origin), size: CGSize(frame.size))
  }
}

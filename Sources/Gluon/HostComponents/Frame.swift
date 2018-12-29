//
//  Size.swift
//  Gluon
//
//  Created by Max Desiatov on 29/12/2018.
//

public struct Point: Equatable {
  public let x: Double
  public let y: Double

  static var zero: Point {
    return Point(x: 0, y: 0)
  }
}

public struct Size: Equatable {
  public let width: Double
  public let height: Double

  static var zero: Size {
    return Size(width: 0, height: 0)
  }
}

public struct Frame: Equatable {
  public let origin: Point
  public let size: Size

  init(_ origin: Point, _ size: Size) {
    self.origin = origin
    self.size = size
  }

  static var zero: Frame {
    return Frame(.zero, .zero)
  }
}

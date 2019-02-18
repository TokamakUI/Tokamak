//
//  Rectangle.swift
//  Tokamak
//
//  Created by Max Desiatov on 29/12/2018.
//

public struct Point: Equatable {
  public let x: Double
  public let y: Double

  public init(x: Double, y: Double) {
    self.x = x
    self.y = y
  }

  public static var zero: Point {
    return Point(x: 0, y: 0)
  }
}

public struct Size: Equatable {
  public let width: Double
  public let height: Double

  public init(width: Double, height: Double) {
    self.width = width
    self.height = height
  }

  public static var zero: Size {
    return Size(width: 0, height: 0)
  }
}

public struct Rectangle: Equatable {
  public let origin: Point
  public let size: Size

  public init(_ origin: Point, _ size: Size) {
    self.origin = origin
    self.size = size
  }

  public static var zero: Rectangle {
    return Rectangle(.zero, .zero)
  }
}

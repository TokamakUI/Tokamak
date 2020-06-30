//
//  File.swift
//
//
//  Created by Carson Katri on 6/28/20.
//

public struct UnitPoint: Hashable {
  public var x: CGFloat
  public var y: CGFloat

  public init() {
    self.init(x: 0, y: 0)
  }

  public init(x: CGFloat, y: CGFloat) {
    self.x = x
    self.y = y
  }

  public static let zero: UnitPoint = .init()
  public static let center: UnitPoint = .init(x: 0.5, y: 0.5)
  public static let leading: UnitPoint = .init(x: 0, y: 0.5)
  public static let trailing: UnitPoint = .init(x: 1, y: 0.5)
  public static let top: UnitPoint = .init(x: 0.5, y: 1)
  public static let bottom: UnitPoint = .init(x: 0.5, y: 0)
  public static let topLeading: UnitPoint = .init(x: 0, y: 1)
  public static let topTrailing: UnitPoint = .init(x: 1, y: 1)
  public static let bottomLeading: UnitPoint = .init(x: 0, y: 0)
  public static let bottomTrailing: UnitPoint = .init(x: 1, y: 0)
}

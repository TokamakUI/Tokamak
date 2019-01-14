//
//  Style.swift
//  Gluon
//
//  Created by Max Desiatov on 31/12/2018.
//

public protocol StyleProps {
  var style: Style? { get }
}

public enum Layout: Equatable {
  case frame(Rectangle)
  case constraints([Constraint])

  public static func constraint(_ constraint: Constraint) -> Layout {
    return .constraints([constraint])
  }
}

public struct Style: Equatable {
  public let alpha: Double?
  public let backgroundColor: Color?
  public let center: Point?
  public let clipsToBounds: Bool?
  public let isHidden: Bool?
  public let layout: Layout?

  public init(
    alpha: Double? = nil,
    backgroundColor: Color? = nil,
    center: Point? = nil,
    clipsToBounds: Bool? = nil,
    isHidden: Bool? = nil,
    _ layout: Layout? = nil
  ) {
    self.alpha = alpha
    self.backgroundColor = backgroundColor
    self.center = center
    self.clipsToBounds = clipsToBounds
    self.isHidden = isHidden
    self.layout = layout
  }
}

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
    isHidden: Bool? = nil
  ) {
    self.alpha = alpha
    self.backgroundColor = backgroundColor
    self.center = center
    self.clipsToBounds = clipsToBounds
    self.isHidden = isHidden
    layout = nil
  }

  public init(
    alpha: Double? = nil,
    backgroundColor: Color? = nil,
    center: Point? = nil,
    clipsToBounds: Bool? = nil,
    isHidden: Bool? = nil,
    _ frame: Rectangle
  ) {
    self.alpha = alpha
    self.backgroundColor = backgroundColor
    self.center = center
    self.clipsToBounds = clipsToBounds
    self.isHidden = isHidden

    layout = .frame(frame)
  }

  public init(
    alpha: Double? = nil,
    backgroundColor: Color? = nil,
    center: Point? = nil,
    clipsToBounds: Bool? = nil,
    isHidden: Bool? = nil,
    _ constraint: Constraint
  ) {
    self.alpha = alpha
    self.backgroundColor = backgroundColor
    self.center = center
    self.clipsToBounds = clipsToBounds
    self.isHidden = isHidden

    layout = .constraints([constraint])
  }

  public init(
    alpha: Double? = nil,
    backgroundColor: Color? = nil,
    center: Point? = nil,
    clipsToBounds: Bool? = nil,
    isHidden: Bool? = nil,
    _ constraints: [Constraint]
  ) {
    self.alpha = alpha
    self.backgroundColor = backgroundColor
    self.center = center
    self.clipsToBounds = clipsToBounds
    self.isHidden = isHidden

    layout = .constraints(constraints)
  }
}

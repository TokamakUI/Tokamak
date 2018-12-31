//
//  Style.swift
//  Gluon
//
//  Created by Max Desiatov on 31/12/2018.
//

public protocol StyleProps {
  var style: Style? { get }
}

public struct Style: Equatable {
  public let alpha: Double?
  public let backgroundColor: Color?
  public let center: Point?
  public let clipsToBounds: Bool?
  public let frame: Rectangle?
  public let isHidden: Bool?

  public init(
    alpha: Double? = nil,
    backgroundColor: Color? = nil,
    center: Point? = nil,
    clipsToBounds: Bool? = nil,
    frame: Rectangle? = nil,
    isHidden: Bool? = nil
  ) {
    self.alpha = alpha
    self.backgroundColor = backgroundColor
    self.center = center
    self.clipsToBounds = clipsToBounds
    self.frame = frame
    self.isHidden = isHidden
  }
}

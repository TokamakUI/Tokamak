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
  public let clipsToBounds: Bool?
  public let center: Point?
  public let frame: Rectangle?
  public let isHidden: Bool?
}

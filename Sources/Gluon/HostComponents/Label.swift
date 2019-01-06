//
//  Label.swift
//  Gluon
//
//  Created by Max Desiatov on 02/12/2018.
//

public struct Label: HostComponent {
  public struct Props: Equatable, StyleProps {
    public let alignment: TextAlignment
    public let style: Style?

    public init(alignment: TextAlignment = .natural, _ style: Style? = nil) {
      self.alignment = alignment
      self.style = style
    }
  }

  public typealias Children = String
}

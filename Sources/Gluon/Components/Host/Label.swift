//
//  Label.swift
//  Gluon
//
//  Created by Max Desiatov on 02/12/2018.
//

public struct Label: HostComponent {
  public struct Props: Equatable, StyleProps, Default {
    public static var defaultValue: Props {
      return Props()
    }

    public let alignment: TextAlignment
    public let style: Style?
    public let textColor: Color?

    public init(
      alignment: TextAlignment = .natural,
      textColor: Color? = nil,
      _ style: Style? = nil
    ) {
      self.alignment = alignment
      self.textColor = textColor
      self.style = style
    }
  }

  public typealias Children = String
}

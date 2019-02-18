//
//  Label.swift
//  Tokamak
//
//  Created by Max Desiatov on 02/12/2018.
//

public struct Label: HostComponent {
  public struct Props: Equatable, StyleProps, Default {
    public static var defaultValue: Props {
      return Props()
    }

    public let alignment: TextAlignment
    public let lineBreakMode: LineBreakMode
    public let numberOfLines: Int
    public let style: Style?
    public let textColor: Color?

    public init(
      alignment: TextAlignment = .natural,
      lineBreakMode: LineBreakMode = .truncateTail,
      numberOfLines: Int = 1,
      textColor: Color? = nil,
      _ style: Style? = nil
    ) {
      self.alignment = alignment
      self.lineBreakMode = lineBreakMode
      self.numberOfLines = numberOfLines
      self.textColor = textColor
      self.style = style
    }
  }

  public typealias Children = String
}

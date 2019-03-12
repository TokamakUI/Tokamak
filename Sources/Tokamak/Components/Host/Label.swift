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
    public let text: String
    public let textColor: Color?

    public init(
      _ style: Style? = nil,
      alignment: TextAlignment = .natural,
      lineBreakMode: LineBreakMode = .truncateTail,
      numberOfLines: Int = 1,
      text: String = "",
      textColor: Color? = nil
    ) {
      self.alignment = alignment
      self.lineBreakMode = lineBreakMode
      self.numberOfLines = numberOfLines
      self.text = text
      self.textColor = textColor
      self.style = style
    }
  }

  public typealias Children = [AnyNode]
}

extension Label.Props: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self.init(text: value)
  }
}

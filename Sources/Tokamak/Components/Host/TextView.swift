//
//  TextView.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 3/27/19.
//

public struct TextView: HostComponent {
  public struct Props: Equatable, StyleProps {
    public let style: Style?
    public let allowsEditingTextAttributes: Bool
    public let isEditable: Bool
    public let text: String?
    public let textAlignment: TextAlignment
    public let textColor: Color?

    public init(
      _ style: Style? = nil,
      allowsEditingTextAttributes: Bool = false,
      isEditable: Bool = true,
      text: String? = "",
      textAlignment: TextAlignment = .natural,
      textColor: Color? = nil
    ) {
      self.style = style
      self.allowsEditingTextAttributes = allowsEditingTextAttributes
      self.isEditable = isEditable
      self.text = text
      self.textAlignment = textAlignment
      self.textColor = textColor
    }
  }

  public typealias Children = Null
}

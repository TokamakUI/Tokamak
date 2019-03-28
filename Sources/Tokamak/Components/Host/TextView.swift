//
//  TextView.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 3/27/19.
//

public struct TextView: HostComponent {
  public struct Props: Equatable, StyleProps, ValueControlProps {
    public let style: Style?
    public let allowsEditingTextAttributes: Bool
    public let isEditable: Bool
    public let textAlignment: TextAlignment
    public let textColor: Color?
    public let scrollOptions: ScrollOptions?
    public let value: String
    public let valueHandler: Handler<String>?

    public init(
      _ style: Style? = nil,
      allowsEditingTextAttributes: Bool = false,
      isEditable: Bool = true,
      scrollOptions: ScrollOptions? = nil,
      textAlignment: TextAlignment = .natural,
      textColor: Color? = nil,
      value: String = "",
      valueHandler: Handler<String>? = nil
    ) {
      self.style = style
      self.allowsEditingTextAttributes = allowsEditingTextAttributes
      self.isEditable = isEditable
      self.textAlignment = textAlignment
      self.textColor = textColor
      self.scrollOptions = scrollOptions
      self.value = value
      self.valueHandler = valueHandler
    }
  }

  public typealias Children = Null
}

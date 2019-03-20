//
//  Throbber.swift
//  Tokamak
//
//  Created by Max Desiatov on 20/03/2019.
//

public struct Throbber: HostComponent {
  public struct Props: Equatable, StyleProps {
    public enum Variety {
      case whiteLarge
      case white
      case gray
    }

    /// Value of this property overrides the value of `variety`
    public let color: Color?
    public let isAnimating: Bool
    public let hidesWhenStopped: Bool
    public let style: Style?
    public let variety: Variety

    public init(
      _ style: Style? = nil,
      color: Color? = nil,
      isAnimating: Bool = false,
      hidesWhenStopped: Bool = true,
      variety: Variety = .gray
    ) {
      self.style = style
      self.color = color
      self.isAnimating = isAnimating
      self.hidesWhenStopped = hidesWhenStopped
      self.variety = variety
    }
  }

  public typealias Children = Null
}

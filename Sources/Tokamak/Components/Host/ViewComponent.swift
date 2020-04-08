//
//  View.swift
//  Tokamak
//
//  Created by Max Desiatov on 29/12/2018.
//

public struct ViewComponent: HostComponent {
  public typealias Children = [AnyNode]

  public struct Props: Equatable, StyleProps, Default {
    public static var defaultValue: Props {
      Props()
    }

    public let style: Style?

    public init(_ style: Style? = nil) {
      self.style = style
    }
  }
}

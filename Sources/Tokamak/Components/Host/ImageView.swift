//
//  ImageView.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 2/17/19.
//

public struct ImageView: HostComponent {
  public typealias Children = [AnyNode]

  public struct Props: Equatable, StyleProps {
    public let image: Image
    public let style: Style?

    public init(
      _ style: Style? = nil,
      image: Image
    ) {
      self.image = image
      self.style = style
    }
  }
}

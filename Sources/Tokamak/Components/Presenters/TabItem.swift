//
//  TabItem.swift
//  Tokamak
//
//  Created by Max Desiatov on 04/02/2019.
//

public struct TabItem: HostComponent {
  public struct Props: Equatable {
    public let badgeColor: Color?
    public let badgeValue: String?
    public let image: Image?
    public let selectedImage: Image?
    public let title: String?

    public init(
      badgeColor: Color? = nil,
      badgeValue: String? = nil,
      image: Image? = nil,
      selectedImage: Image? = nil,
      title: String? = nil
    ) {
      self.badgeColor = badgeColor
      self.badgeValue = badgeValue
      self.image = image
      self.selectedImage = selectedImage
      self.title = title
    }
  }

  public typealias Children = AnyNode
}

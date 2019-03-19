//
//  TabController.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 3/13/19.
//

public struct TabController: HostComponent, RefComponent {
  public typealias RefTarget = UITabBarController

  public typealias Children = [AnyNode]

  public struct Props: Equatable {
    public let onSelect: Handler<Int>?
    public let isAnimated: Bool
    public let selectedIndex: State<Int>?

    public init(
      onSelect: Handler<Int>? = nil,
      isAnimated: Bool = false,
      selectedIndex: State<Int>? = nil
    ) {
      self.onSelect = onSelect
      self.isAnimated = isAnimated
      self.selectedIndex = selectedIndex
    }
  }
}

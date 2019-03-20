//
//  TabController.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 3/13/19.
//

public struct TabController: HostComponent {
  public typealias Children = [AnyNode]

  public struct Props: Equatable {
    public let isAnimated: Bool
    public let selectedIndex: State<Int>?

    public init(
      isAnimated: Bool = false,
      selectedIndex: State<Int>? = nil
    ) {
      self.isAnimated = isAnimated
      self.selectedIndex = selectedIndex
    }
  }
}

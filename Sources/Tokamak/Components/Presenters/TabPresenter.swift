//
//  TabPresenter.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 3/13/19.
//

public struct TabPresenter: HostComponent {
  public typealias Children = [AnyNode]

  public struct Props: Equatable {
    public let isAnimated: Bool
    public let selectedIndex: Binding<Int>?

    public init(
      isAnimated: Bool = false,
      selectedIndex: Binding<Int>? = nil
    ) {
      self.isAnimated = isAnimated
      self.selectedIndex = selectedIndex
    }
  }
}

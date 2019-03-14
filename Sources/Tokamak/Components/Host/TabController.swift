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

    public init(isAnimated: Bool = false) {
      self.isAnimated = isAnimated
    }
  }
}

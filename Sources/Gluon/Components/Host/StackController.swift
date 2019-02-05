//
//  StackController.swift
//  Gluon
//
//  Created by Max Desiatov on 06/01/2019.
//

public struct StackController: HostComponent {
  public struct Item: Equatable {
    public let navigation: NavigationItem?
    public let node: AnyNode

    public init(navigation: NavigationItem, node: AnyNode) {
      self.navigation = navigation
      self.node = node
    }
  }

  public typealias Children = [AnyNode]

  public struct Props: Equatable {
    public let hidesBarsWhenKeyboardAppears: Bool?
    public let popAnimated: Bool
    public let pushAnimated: Bool
    public let onPop: Handler<()>
  }
}

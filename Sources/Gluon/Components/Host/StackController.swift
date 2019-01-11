//
//  StackController.swift
//  Gluon
//
//  Created by Max Desiatov on 06/01/2019.
//

public struct StackController: HostComponent {
  public typealias Children = [AnyNode]

  public struct Props: Equatable {
    public let hidesBarsWhenKeyboardAppears: Bool?
    public let popAnimated: Bool
    public let pushAnimated: Bool
    public let onPop: Handler<()>
  }
}

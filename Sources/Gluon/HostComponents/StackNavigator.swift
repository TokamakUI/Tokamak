//
//  StackNavigator.swift
//  Gluon
//
//  Created by Max Desiatov on 31/12/2018.
//

public struct StackNavigator: HostComponent {
  public struct Props: Equatable {
    public let hidesBarsWhenKeyboardAppears: Bool
  }

  public typealias Children = [Node]
}

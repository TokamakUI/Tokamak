//
//  StackPresenter.swift
//  Gluon
//
//  Created by Max Desiatov on 31/12/2018.
//

public struct StackPresenter: HostComponent {
  public struct Props: Equatable {
    public let hidesBarsWhenKeyboardAppears: Bool?
    public let popAnimated: Bool
    public let pushAnimated: Bool

    public init(
      hidesBarsWhenKeyboardAppears: Bool? = nil,
      popAnimated: Bool = true,
      pushAnimated: Bool = true
    ) {
      self.hidesBarsWhenKeyboardAppears = hidesBarsWhenKeyboardAppears
      self.popAnimated = popAnimated
      self.pushAnimated = pushAnimated
    }
  }

  public typealias Children = [Node]
}

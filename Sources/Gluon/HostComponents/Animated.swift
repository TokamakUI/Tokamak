//
//  Animated.swift
//  Gluon
//
//  Created by Max Desiatov on 02/01/2019.
//

public protocol Animatable: Component {}

public struct Animated<T: Animatable>: HostComponent {
  public struct Props: Equatable {
    public struct AnimationCurve {}

    public let duration: Second
    public let initial: T.Props
    public let isRunning: Bool
    public let isReversed: Bool
    public let target: T.Props
  }

  public typealias Children = T.Children
}

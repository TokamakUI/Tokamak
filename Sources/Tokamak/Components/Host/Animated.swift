//
//  Animated.swift
//  Tokamak
//
//  Created by Max Desiatov on 02/01/2019.
//

protocol Animatable: Component {}

struct Animated<T: Component, U: Equatable>: HostComponent {
  public struct Props: Equatable {
    public struct AnimationCurve {}

    public let duration: Second
    public let initial: T.Props
    public let isRunning: Bool
    public let isReversed: Bool
    public let keyPath: KeyPath<T.Props, U>
    public let target: U
  }

  public typealias Children = T.Children
}

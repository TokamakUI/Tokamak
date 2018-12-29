//
//  StackView.swift
//  Gluon
//
//  Created by Max Desiatov on 02/12/2018.
//

public struct StackViewProps: Equatable {
  public enum Axis: Equatable {
    case horizontal
    case vertical
  }

  public enum Distribution: Equatable {
    case fill
    case fillEqually
    case fillProportionally
    case equalSpacing
  }

  public let axis: Axis
  public let distribution: Distribution
  public let frame: Frame

  public init(axis: Axis = .horizontal,
              distribution: Distribution = .fill,
              frame: Frame) {
    self.axis = axis
    self.distribution = distribution
    self.frame = frame
  }
}

public struct StackView: HostComponent {
  public typealias Props = StackViewProps
  public typealias Children = [Node]
}

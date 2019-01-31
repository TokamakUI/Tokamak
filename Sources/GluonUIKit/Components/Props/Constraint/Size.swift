//
//  Size.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 17/01/2019.
//

import Gluon
import UIKit

extension Constraint.Size.Attribute {
  var anchor: KeyPath<UIView, NSLayoutDimension> {
    switch self {
    case .height:
      return \.heightAnchor
    case .width:
      return \.widthAnchor
    }
  }
}

extension Constraint.Size {
  func constraint(
    source: Attribute,
    current: UIView,
    parent: UIView?,
    next: UIView?
  ) -> [NSLayoutConstraint] {
    let firstAnchor = source.anchor
    let secondAnchor = attribute.anchor

    switch target {
    case .own:
      return [current[keyPath: firstAnchor].constraint(
        equalToConstant: CGFloat(constant)
      )]
    case let .external(target):
      let secondView: UIView?
      switch target {
      case .next:
        secondView = next
      case .parent:
        secondView = parent
      }

      guard let second = secondView?[keyPath: secondAnchor] else { return [] }

      return [current[keyPath: firstAnchor].constraint(
        equalTo: second,
        multiplier: CGFloat(multiplier),
        constant: CGFloat(constant)
      )]
    }
  }
}

protocol OwnConstraint {
  var firstAnchor: KeyPath<UIView, NSLayoutDimension> { get }
  var secondAnchor: KeyPath<UIView, NSLayoutDimension> { get }
  var target: Constraint.OwnTarget { get }
  var constant: Double { get }
  var multiplier: Double { get }
}

extension OwnConstraint {
  func constraint(
    current: UIView,
    parent: UIView?,
    next: UIView?
  ) -> [NSLayoutConstraint] {
    switch target {
    case .own:
      return [current[keyPath: firstAnchor].constraint(
        equalToConstant: CGFloat(constant)
      )]
    case let .external(target):
      let secondView: UIView?
      switch target {
      case .next:
        secondView = next
      case .parent:
        secondView = parent
      }

      guard let second = secondView?[keyPath: secondAnchor] else { return [] }

      return [current[keyPath: firstAnchor].constraint(
        equalTo: second,
        multiplier: CGFloat(multiplier),
        constant: CGFloat(constant)
      )]
    }
  }
}

protocol OffsetConstraint {
  var firstAnchor: KeyPath<UIView, NSLayoutDimension> { get }
  var secondAnchor: KeyPath<UIView, NSLayoutDimension> { get }
  var target: Constraint.Target { get }
  var constant: Double { get }
  var multiplier: Double { get }
}

extension OffsetConstraint {
  func constraint(
    current: UIView,
    parent: UIView?,
    next: UIView?
  ) -> [NSLayoutConstraint] {
    let secondView: UIView?
    switch target {
    case .next:
      secondView = next
    case .parent:
      secondView = parent
    }

    guard let second = secondView?[keyPath: secondAnchor] else { return [] }

    return [current[keyPath: firstAnchor].constraint(
      equalTo: second,
      multiplier: CGFloat(multiplier),
      constant: CGFloat(constant)
    )]
  }
}

protocol XAxisConstraint {
    var firstAnchor: KeyPath<UIView, NSLayoutXAxisAnchor> { get }
    var secondAnchor: KeyPath<UIView, NSLayoutXAxisAnchor> { get }
    var target: Constraint.Target { get }
    var constant: Double { get }
    var multiplier: Double { get }
}

extension XAxisConstraint {
    func constraint(
        current: UIView,
        parent: UIView?,
        next: UIView?
        ) -> [NSLayoutConstraint] {
        let secondView: UIView?
        switch target {
        case .next:
            secondView = next
        case .parent:
            secondView = parent
        }
        
        guard let second = secondView?[keyPath: secondAnchor] else { return [] }
        
        return [current[keyPath: firstAnchor].constraint(
            equalTo: second,
            multiplier: CGFloat(multiplier),
            constant: CGFloat(constant)
            )]
    }
}


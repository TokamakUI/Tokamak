//
//  Layout.swift
//  Gluon
//
//  Created by Max Desiatov on 16/10/2018.
//

import Foundation

public struct Constraint: BaseComponent {
  public let props: Props
  public let children: [Node]

  enum Target {
    case next
    case container
    case own
  }

  struct HorizontalLocation: Equatable {
    enum Attribute {
      case left
      case right
    }

    let target: Target
    let attribute: Attribute?
    let offset: Double

    static func equal(to target: Target,
                      _ attribute: Attribute? = nil,
                      offset: Double = 0) -> HorizontalLocation {
      return HorizontalLocation(target: target,
                                attribute: attribute,
                                offset: offset)
    }
  }

  struct VerticalLocation: Equatable {
    enum Attribute {
      case top
      case bottom
      case baseline
    }

    let target: Target
    let attribute: Attribute?
    let offset: Double

    static func equal(to target: Target,
                      _ attribute: Attribute? = nil,
                      offset: Double = 0) -> VerticalLocation {
      return VerticalLocation(target: target,
                              attribute: attribute,
                              offset: offset)
    }
  }

  enum CenterTarget {
    case next
    case container
  }

  struct Center: Equatable {
    let target: CenterTarget

    static func equal(to target: CenterTarget) -> Center {
      return Center(target: target)
    }
  }

  struct Size: Equatable {
    enum Attribute {
      case width
      case height
    }

    let target: Target
    let attibute: Attribute?
    let offset: Double
    let multiplier: Double

    static func equal(to target: Target,
                      _ attribute: Attribute? = nil,
                      offset: Double = 0,
                      multiplier: Double = 1) -> Size {
      return Size(target: target,
                  attibute: attribute,
                  offset: offset,
                  multiplier: multiplier)
    }
  }

  public struct Props: Equatable {
    let baseline: VerticalLocation?
    let bottom: VerticalLocation?
    let center: Center?
    let centerX: HorizontalLocation?
    let centerY: VerticalLocation?
    let height: Size?
    let left: HorizontalLocation?
    let right: HorizontalLocation?
    let top: VerticalLocation?
    let width: Size?

    init(baseline: VerticalLocation? = nil,
         bottom: VerticalLocation? = nil,
         center: Center? = nil,
         centerX: HorizontalLocation? = nil,
         centerY: VerticalLocation? = nil,
         height: Size? = nil,
         left: HorizontalLocation? = nil,
         right: HorizontalLocation? = nil,
         top: VerticalLocation? = nil,
         width: Size? = nil) {
      self.width = width
      self.height = height
      self.centerX = centerX
      self.centerY = centerY
      self.center = center
      self.baseline = baseline
      self.top = top
      self.bottom = bottom
      self.left = left
      self.right = right
    }
  }
}

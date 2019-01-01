//
//  Layout.swift
//  Gluon
//
//  Created by Max Desiatov on 16/10/2018.
//

public struct LayoutConstraint: HostComponent {
  public struct Props: Equatable {
    public enum Target {
      case next
      case container
      case own
    }

    public struct HorizontalLocation: Equatable {
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

    public struct VerticalLocation: Equatable {
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

    public enum CenterTarget {
      case next
      case container
    }

    public struct Center: Equatable {
      let target: CenterTarget

      static func equal(to target: CenterTarget) -> Center {
        return Center(target: target)
      }
    }

    public struct Size: Equatable {
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

    public let baseline: VerticalLocation?
    public let bottom: VerticalLocation?
    public let center: Center?
    public let centerX: HorizontalLocation?
    public let centerY: VerticalLocation?
    public let height: Size?
    public let left: HorizontalLocation?
    public let right: HorizontalLocation?
    public let top: VerticalLocation?
    public let width: Size?

    public init(baseline: VerticalLocation? = nil,
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

  public typealias Children = [Node]
}

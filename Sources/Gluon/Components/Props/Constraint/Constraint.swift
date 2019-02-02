//
//  Constraint.swift
//  Gluon
//
//  Created by Max Desiatov on 16/10/2018.
//

public enum Constraint: Equatable {
  public enum Target {
    case next
    case parent
  }

  public enum OwnTarget: Equatable {
    case external(Target)
    case own
  }

  public struct HorizontalLocation: Equatable {
    public enum Attribute {
      case left
      case right
    }

    public let target: Target
    public let attribute: Attribute?
    public let offset: Double

    public static func equal(
      to target: Target,
      _ attribute: Attribute? = nil,
      offset: Double = 0
    ) -> HorizontalLocation {
      return HorizontalLocation(
        target: target,
        attribute: attribute,
        offset: offset
      )
    }
  }

  public struct VerticalLocation: Equatable {
    public enum Attribute {
      case top
      case bottom
      case baseline
    }

    public let target: Target
    public let attribute: Attribute?
    public let offset: Double

    public static func equal(
      to target: Target,
      _ attribute: Attribute? = nil,
      offset: Double = 0
    ) -> VerticalLocation {
      return VerticalLocation(
        target: target,
        attribute: attribute,
        offset: offset
      )
    }
  }

  public struct Center: Equatable {
    public let target: Target

    public static func equal(to target: Target) -> Center {
      return Center(target: target)
    }
  }

  public struct Size: Equatable {
    public enum ExternalTarget {
      case next
      case parent
    }

    public enum Target: Equatable {
      case external(ExternalTarget)
      case own
    }

    public enum Attribute {
      case width
      case height

      public func equal(to constant: Double) -> Size {
        return Size(
          target: .own,
          attribute: self,
          constant: constant,
          multiplier: 0
        )
      }

      public func equal(
        to target: ExternalTarget,
        offset: Double = 0,
        multiplier: Double = 1
      ) -> Size {
        return Size(
          target: .external(target),
          attribute: self,
          constant: offset,
          multiplier: multiplier
        )
      }
    }

    public let target: Target
    public let attribute: Attribute
    public let constant: Double
    public let multiplier: Double
  }

  case firstBaseline(FirstBaseline)
  case lastBaseline(LastBaseline)

  case center(Center)
  case centerX(CenterX)
  case centerY(CenterY)

  case width(Width)
  case height(Height)
  case size(SizeConstraint)

  case edges(Edges)
  case leading(Leading)
  case trailing(Trailing)
  case left(Left)
  case right(Right)
  case top(Top)
  case bottom(Bottom)
}

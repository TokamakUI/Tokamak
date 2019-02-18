//
//  Constraint.swift
//  Tokamak
//
//  Created by Max Desiatov on 16/10/2018.
//

public enum Constraint: Equatable {
  public enum SafeAreaTarget: Equatable {
    case external(Target)
    case safeArea
  }

  public enum Target {
    case next
    case parent
  }

  public enum OwnTarget: Equatable {
    case external(Target)
    case own
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

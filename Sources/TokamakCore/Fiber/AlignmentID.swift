//
//  File.swift
//
//
//  Created by Carson Katri on 2/18/22.
//

import Foundation

public protocol AlignmentID {
  static func defaultValue(in context: ViewDimensions) -> CGFloat
}

/// An alignment position along the horizontal axis.
@frozen public struct HorizontalAlignment: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }

  let id: AlignmentID.Type

  public init(_ id: AlignmentID.Type) {
    self.id = id
  }
}

extension HorizontalAlignment {
  public static let leading = Self(Leading.self)

  private enum Leading: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
      0
    }
  }

  public static let center = Self(Center.self)

  private enum Center: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
      context.width / 2
    }
  }

  public static let trailing = Self(Leading.self)

  private enum Trailing: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
      context.width
    }
  }
}

@frozen public struct VerticalAlignment: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }

  let id: AlignmentID.Type

  public init(_ id: AlignmentID.Type) {
    self.id = id
  }
}

extension VerticalAlignment {
  public static let top = Self(Top.self)
  private enum Top: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
      0
    }
  }

  public static let center = Self(Center.self)
  private enum Center: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
      context.height / 2
    }
  }

  public static let bottom = Self(Bottom.self)
  private enum Bottom: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
      context.height
    }
  }

  // TODO: Add baseline vertical alignment guides.
  // public static let firstTextBaseline: VerticalAlignment
  // public static let lastTextBaseline: VerticalAlignment
}

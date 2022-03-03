//
//  File.swift
//
//
//  Created by Carson Katri on 2/17/22.
//

import Foundation

public struct ViewGeometry: Equatable {
  @_spi(TokamakCore) public let origin: ViewOrigin
  @_spi(TokamakCore) public let dimensions: ViewDimensions
}

/// The position of the `View` relative to its parent.
public struct ViewOrigin: Equatable {
  @_spi(TokamakCore) public let origin: CGPoint

  @_spi(TokamakCore) public var x: CGFloat { origin.x }
  @_spi(TokamakCore) public var y: CGFloat { origin.y }
}

public struct ViewDimensions: Equatable {
  @_spi(TokamakCore) public let size: CGSize
  @_spi(TokamakCore) public let alignmentGuides: [ObjectIdentifier: CGFloat]

  public var width: CGFloat { size.width }
  public var height: CGFloat { size.height }

  public subscript(guide: HorizontalAlignment) -> CGFloat {
    self[explicit: guide] ?? guide.id.defaultValue(in: self)
  }

  public subscript(guide: VerticalAlignment) -> CGFloat {
    self[explicit: guide] ?? guide.id.defaultValue(in: self)
  }

  public subscript(explicit guide: HorizontalAlignment) -> CGFloat? {
    alignmentGuides[.init(guide.id)]
  }

  public subscript(explicit guide: VerticalAlignment) -> CGFloat? {
    alignmentGuides[.init(guide.id)]
  }
}

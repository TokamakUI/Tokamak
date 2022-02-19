//
//  File.swift
//
//
//  Created by Carson Katri on 2/17/22.
//

import Foundation

public struct ViewDimensions: Equatable {
  @_spi(TokamakCore) public let origin: CGPoint
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

extension ViewDimensions: CustomDebugStringConvertible {
  public var debugDescription: String {
    "(\(origin.x), \(origin.y)), (\(width), \(height))"
  }
}

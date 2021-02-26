//
//  Alignment.swift
//  SwiftUILayout
//
//  Created by Florian Kugler on 26-10-2020.
//
//  NOTE: This file is a product of objc.io. Please see LICENSE.md
//  From https://github.com/objcio/S01E232-swiftui-layout-explained-hstack-with-flexible-views

// NOTE: The top/bottom definitions depend on the Y-axis of the destination
// coordinate system. Perhaps this ought to be configurable somehow.

public struct Alignment {
  public var horizontal: HorizontalAlignment
  public var vertical: VerticalAlignment

  public static let center = Self(horizontal: .center, vertical: .center)
  public static let leading = Self(horizontal: .leading, vertical: .center)
  public static let trailing = Self(horizontal: .trailing, vertical: .center)
  public static let top = Self(horizontal: .center , vertical: .top)
  public static let topLeading = Self(horizontal: .leading, vertical: .top)
  public static let topTrailing = Self(horizontal: .trailing, vertical: .top)
  public static let bottom = Self(horizontal: .center , vertical: .bottom)
  public static let bottomLeading = Self(horizontal: .leading, vertical: .bottom)
  public static let bottomTrailing = Self(horizontal: .trailing, vertical: .bottom)
}

public struct HorizontalAlignment: Equatable {
  var alignmentID: AlignmentID.Type
  public static let leading = Self(alignmentID: HLeading.self)
  public static let center = Self(alignmentID: HCenter.self)
  public static let trailing = Self(alignmentID: HTrailing.self)
  public static func == (a: HorizontalAlignment, b: HorizontalAlignment) -> Bool {
    a.alignmentID == b.alignmentID
  }
}

public struct VerticalAlignment: Equatable {
  var alignmentID: AlignmentID.Type
  public static let top = Self(alignmentID: VTop.self)
  public static let center = Self(alignmentID: VCenter.self)
  public static let bottom = Self(alignmentID: VBottom.self)
  public static func == (a: VerticalAlignment, b: VerticalAlignment) -> Bool {
    a.alignmentID == b.alignmentID
  }
}

protocol AlignmentID {
  static func defaultValue(in context: CGSize) -> CGFloat
}

enum VTop: AlignmentID {
  static func defaultValue(in context: CGSize) -> CGFloat { 0 }
}

enum VCenter: AlignmentID {
  static func defaultValue(in context: CGSize) -> CGFloat { context.height/2 }
}

enum VBottom: AlignmentID {
  static func defaultValue(in context: CGSize) -> CGFloat { context.height }
}

enum HLeading: AlignmentID {
  static func defaultValue(in context: CGSize) -> CGFloat { 0 }
}

enum HCenter: AlignmentID {
  static func defaultValue(in context: CGSize) -> CGFloat { context.width/2 }
}

enum HTrailing: AlignmentID {
  static func defaultValue(in context: CGSize) -> CGFloat { context.width }
}

extension Alignment {
  public func point(for size: CGSize) -> CGPoint {
    let x = horizontal.alignmentID.defaultValue(in: size)
    let y = vertical.alignmentID.defaultValue(in: size)
    return CGPoint(x: x, y: y)
  }
}

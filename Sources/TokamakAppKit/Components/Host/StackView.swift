//
//  StackView.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 29/12/2018.
//

import AppKit
import Tokamak

final class TokamakStackView: NSStackView, Default {
  static var defaultValue: TokamakStackView {
    TokamakStackView()
  }
}

extension NSLayoutConstraint.Attribute {
  public init?(_ alignment: VerticalAlignment) {
    switch alignment {
    case .top:
      self = .top
    case .bottom:
      self = .bottom
    case .center:
      self = .centerY
    }
  }
}

extension NSUserInterfaceLayoutOrientation {
  public init(_ axis: StackView.Props.Axis) {
    switch axis {
    case .horizontal:
      self = .horizontal
    case .vertical:
      self = .vertical
    }
  }
}

extension NSStackView.Distribution {
  public init(_ distribution: StackView.Props.Distribution) {
    switch distribution {
    case .fill:
      self = .fill
    case .fillEqually:
      self = .fillEqually
    case .fillProportionally:
      self = .fillProportionally
    case .equalSpacing:
      self = .equalSpacing
    }
  }
}

extension HStack: NSViewComponent {
  typealias Target = TokamakStackView

  static func update(view box: ViewBox<TokamakStackView>,
                     _ view: Self) {
    NSLayoutConstraint.Attribute(view.alignment).flatMap {
      box.view.alignment = $0
    }
    box.view.orientation = .horizontal
    if let spacing = view.spacing.flatMap(CoreGraphics.CGFloat.init) {
      box.view.spacing = spacing
    }
  }
}

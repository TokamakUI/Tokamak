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
    return TokamakStackView()
  }
}

extension NSLayoutConstraint.Attribute {
  public init?(_ alignment: StackView.Props.Alignment) {
    switch alignment {
    case .top:
      self = .top
    case .bottom:
      self = .bottom
    case .leading:
      self = .leading
    case .trailing:
      self = .trailing
    case .fill, .center:
      return nil
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

extension StackView: NSViewComponent {
  public typealias RefTarget = NSStackView

  static func update(view box: ViewBox<TokamakStackView>,
                     _ props: StackView.Props,
                     _: [AnyNode]) {
    let view = box.view
    NSLayoutConstraint.Attribute(props.alignment).flatMap {
      view.alignment = $0
    }
    view.orientation = NSUserInterfaceLayoutOrientation(props.axis)
    view.distribution = NSStackView.Distribution(props.distribution)
    view.spacing = CGFloat(props.spacing)
  }
}

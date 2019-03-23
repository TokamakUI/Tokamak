//
//  Throbber.swift
//  TokamakAppKit
//
//  Created by Max Desiatov on 23/03/2019.
//

import Tokamak
import AppKit

final class TokamakProgressIndicator: NSProgressIndicator, Default {
  public static var defaultValue: TokamakProgressIndicator {
    let result = TokamakProgressIndicator()
    result.isIndeterminate = true
    result.style = .spinning
    return result
  }
}

extension Throbber: NSViewComponent {
  public typealias RefTarget = NSProgressIndicator

  static func update(view box: ViewBox<TokamakProgressIndicator>,
                     _ props: Throbber.Props,
                     _: Null) {
    let view = box.view

    view.isDisplayedWhenStopped = !props.hidesWhenStopped

    props.isAnimating ?
      view.startAnimation(nil) :
      view.stopAnimation(nil)
  }
}

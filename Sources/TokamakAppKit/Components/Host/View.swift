//
//  View.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 31/12/2018.
//

import AppKit
import Tokamak

final class TokamakView: NSView, Default {
  public static var defaultValue: TokamakView {
    return TokamakView()
  }
}

extension View: NSViewComponent {
  public typealias RefTarget = NSView

  static func update(view: ViewBox<TokamakView>,
                     _ props: View.Props,
                     _: [AnyNode]) {}
}

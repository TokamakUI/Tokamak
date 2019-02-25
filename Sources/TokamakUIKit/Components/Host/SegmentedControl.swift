//
//  SegmentedControl.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 05/01/2019.
//

import Tokamak
import UIKit

final class TokamakSegmentedControl: UISegmentedControl, Default, ValueStorage {
  static var defaultValue: TokamakSegmentedControl {
    return TokamakSegmentedControl()
  }

  var value: Int {
    get {
      return selectedSegmentIndex
    }
    set {
      selectedSegmentIndex = newValue
    }
  }
}

extension SegmentedControl: UIValueComponent {
  typealias Target = TokamakSegmentedControl
  public typealias RefTarget = UISegmentedControl

  static func update(valueBox: ValueControlBox<TokamakSegmentedControl>,
                     _ props: SegmentedControl.Props,
                     _ children: [String]) {
    let control = valueBox.view

    control.removeAllSegments()

    for (i, child) in children.enumerated() {
      control.insertSegment(withTitle: child, at: i, animated: false)
    }
  }
}

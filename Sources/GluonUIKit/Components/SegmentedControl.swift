//
//  SegmentedControl.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 05/01/2019.
//

import Gluon
import UIKit

final class GluonSegmentedControl: UISegmentedControl, Default, ValueStorage {
  static var defaultValue: GluonSegmentedControl {
    return GluonSegmentedControl()
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
  typealias Target = GluonSegmentedControl

  static func update(valueBox: ValueControlBox<GluonSegmentedControl>,
                     _ props: SegmentedControl.Props,
                     _ children: [String]) {
    let control = valueBox.view

    control.removeAllSegments()

    for (i, child) in children.enumerated() {
      control.insertSegment(withTitle: child, at: i, animated: false)
    }
  }
}

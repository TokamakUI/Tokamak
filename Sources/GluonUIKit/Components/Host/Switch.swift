//
//  Switch.swift
//  Gluon
//
//  Created by Matvii Hodovaniuk on 1/21/19.
//

import Gluon
import UIKit

final class GluonSwitch: UISwitch, Default, ValueStorage {
  static var defaultValue: GluonSwitch {
    return GluonSwitch()
  }

  var value: Bool {
    get {
      return isOn
    }
    set {
      setOn(newValue, animated: isAnimated)
    }
  }

  var isAnimated: Bool = true
}

extension Switch: UIValueComponent {
  typealias Target = GluonSwitch

  static func update(valueBox: ValueControlBox<GluonSwitch>,
                     _ props: Switch.Props,
                     _ children: Null) {
    valueBox.view.isAnimated = props.isAnimated
  }
}

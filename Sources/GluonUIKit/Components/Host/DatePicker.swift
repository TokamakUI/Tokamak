//
//  DatePicker.swift
//  Gluon
//
//  Created by Matvii Hodovaniuk on 2/4/19.
//

import Gluon
import UIKit

final class GluonDatePicker: UIDatePicker, Default, ValueStorage {
  static var defaultValue: GluonDatePicker {
    return GluonDatePicker()
  }

  var value: Date {
    get {
      return date
    }
    set {
      setDate(newValue, animated: isAnimated)
    }
  }

  var isAnimated: Bool = true
}

extension DatePicker: UIValueComponent {
  typealias Target = GluonDatePicker

  static func update(valueBox: ValueControlBox<GluonDatePicker>,
                     _ props: DatePicker.Props,
                     _ children: Null) {
    valueBox.view.isAnimated = props.isAnimated
  }
}

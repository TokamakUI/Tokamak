//
//  DatePicker.swift
//  TokamakUIKit
//
//  Created by Matvii Hodovaniuk on 2/4/19.
//

import Tokamak
import UIKit

final class TokamakDatePicker: UIDatePicker, Default, ValueStorage {
  static var defaultValue: TokamakDatePicker {
    return TokamakDatePicker()
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
  typealias Target = TokamakDatePicker
  public typealias RefTarget = UIDatePicker

  static func update(valueBox: ValueControlBox<TokamakDatePicker>,
                     _ props: DatePicker.Props,
                     _ children: Null) {
    valueBox.view.isAnimated = props.isAnimated
  }
}

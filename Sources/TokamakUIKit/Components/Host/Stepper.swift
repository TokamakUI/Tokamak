//
//  Stepper.swift
//  TokamakUIKit
//
//  Created by Matvii Hodovaniuk on 1/21/19.
//

import Tokamak
import UIKit

final class TokamakStepper: UIStepper, Default, ValueStorage {
  static var defaultValue: TokamakStepper {
    return TokamakStepper()
  }
}

extension Stepper: UIValueComponent {
  typealias Target = TokamakStepper
  public typealias RefTarget = UIStepper

  static func update(valueBox: ValueControlBox<TokamakStepper>,
                     _ props: Stepper.Props,
                     _ children: Null) {
    valueBox.view.stepValue = props.stepValue
    valueBox.view.minimumValue = props.minimumValue
    valueBox.view.maximumValue = props.maximumValue
    valueBox.view.wraps = props.wraps
    valueBox.view.autorepeat = props.autorepeat
  }
}

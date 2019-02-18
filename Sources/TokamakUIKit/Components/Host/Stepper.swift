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

  static func update(valueBox: ValueControlBox<TokamakStepper>,
                     _ props: Stepper.Props,
                     _ children: Null) {}
}

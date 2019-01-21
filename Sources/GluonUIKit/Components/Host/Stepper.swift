//
//  Stepper.swift
//  Gluon
//
//  Created by Matvii Hodovaniuk on 1/21/19.
//

import Gluon
import UIKit

final class GluonStepper: UIStepper, Default, ValueStorage {
  static var defaultValue: GluonStepper {
    return GluonStepper()
  }
}

extension Stepper: UIValueComponent {
  typealias Target = GluonStepper
  
  static func update(valueBox: ValueControlBox<GluonStepper>,
                     _ props: Stepper.Props,
                     _ children: Null) {}
}

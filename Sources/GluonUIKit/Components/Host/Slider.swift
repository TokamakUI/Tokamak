//
//  Slider.swift
//  Gluon
//
//  Created by Max Desiatov on 29/12/2018.
//

import Gluon
import UIKit

final class GluonSlider: UISlider, Default, ValueStorage {
  static var defaultValue: GluonSlider {
    return GluonSlider()
  }
}

extension Slider: UIValueComponent {
  typealias Target = GluonSlider

  static func update(valueBox: ValueControlBox<GluonSlider>,
                     _ props: Slider.Props,
                     _ children: Null) {}
}

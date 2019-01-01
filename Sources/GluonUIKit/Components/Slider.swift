//
//  Slider.swift
//  Gluon
//
//  Created by Max Desiatov on 29/12/2018.
//

import Gluon
import UIKit

final class GluonUISlider: UISlider, Default, ValueStorage {
  static var defaultValue: GluonUISlider {
    return GluonUISlider()
  }
}

extension Slider: UIValueComponent {
  typealias Target = GluonUISlider

  static func update(valueBox: ValueControlBox<GluonUISlider>,
                     _ props: Slider.Props,
                     _ children: Null) {}
}

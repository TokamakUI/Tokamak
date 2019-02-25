//
//  Slider.swift
//  Tokamak
//
//  Created by Max Desiatov on 29/12/2018.
//

import Tokamak
import UIKit

final class TokamakSlider: UISlider, Default, ValueStorage {
  static var defaultValue: TokamakSlider {
    return TokamakSlider()
  }
}

extension Slider: UIValueComponent {
  typealias Target = TokamakSlider
  public typealias RefTarget = UISlider

  static func update(valueBox: ValueControlBox<TokamakSlider>,
                     _ props: Slider.Props,
                     _ children: Null) {}
}

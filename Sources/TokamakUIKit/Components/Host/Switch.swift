//
//  Switch.swift
//  TokamakUIKit
//
//  Created by Matvii Hodovaniuk on 1/21/19.
//

import Tokamak
import UIKit

final class TokamakSwitch: UISwitch, Default, ValueStorage {
  static var defaultValue: TokamakSwitch {
    return TokamakSwitch()
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
  typealias Target = TokamakSwitch
  public typealias RefTarget = UISwitch

  static func update(valueBox: ValueControlBox<TokamakSwitch>,
                     _ props: Switch.Props,
                     _ children: Null) {
    let view = valueBox.view
    view.isAnimated = props.isAnimated
    view.onImage = props.onImage.flatMap { UIImage.from(image: $0) }
    view.offImage = props.onImage.flatMap { UIImage.from(image: $0) }
  }
}

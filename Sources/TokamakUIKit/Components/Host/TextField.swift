//
//  TextField.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 2/22/19.
//

import Tokamak
import UIKit

extension UITextField.ViewMode {
  public init(_ mode: TextField.Props.ViewMode) {
    switch mode {
    case .never:
      self = .never
    case .whileEditing:
      self = .whileEditing
    case .unlessEditing:
      self = .unlessEditing
    case .always:
      self = .always
    }
  }
}

extension UITextAutocapitalizationType {
  public init(_ type: TextField.Props.TextAutocapitalizationType) {
    switch type {
    case .none:
      self = .none
    case .words:
      self = .words
    case .sentences:
      self = .sentences
    case .allCharacters:
      self = .allCharacters
    }
  }
}

extension UITextAutocorrectionType {
  public init(_ type: TextField.Props.TextAutocorrectionType) {
    switch type {
    case .default:
      self = .default
    case .no:
      self = .no
    case .yes:
      self = .yes
    }
  }
}

extension UITextSpellCheckingType {
  public init(_ type: TextField.Props.TextSpellCheckingType) {
    switch type {
    case .default:
      self = .default
    case .no:
      self = .no
    case .yes:
      self = .yes
    }
  }
}

final class TokamakTextField: UITextField, Default, ValueStorage {
  typealias Value = String

  static var defaultValue: TokamakTextField {
    return TokamakTextField()
  }

  var value: String {
    get {
      return text ?? ""
    }
    set {
      text = newValue
    }
  }

  var isAnimated: Bool = true
}

extension TextField: UIValueComponent {
  typealias Target = TokamakTextField

  static func update(valueBox: ValueControlBox<TokamakTextField>,
                     _ props: TextField.Props,
                     _ children: Null) {
    let control = valueBox.view
    control.textColor = UIColor(props.textColor)
    control.textAlignment = NSTextAlignment(props.textAlignment)
    control.placeholder = props.placeholder
    control.clearsOnBeginEditing = props.clearsOnBeginEditing
    control.clearsOnInsertion = props.clearsOnInsertion
//    control.borderStyle = Style.init(props.borderStyle)
    control.clearButtonMode = UITextField.ViewMode(props.clearButtonMode)
    control.autocapitalizationType = UITextAutocapitalizationType(props.autocapitalizationType)
    control.autocorrectionType = UITextAutocorrectionType(props.autocorrectionType)
    control.spellCheckingType = UITextSpellCheckingType(props.spellCheckingType)
  }
}

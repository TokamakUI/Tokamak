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

extension UIKeyboardType {
  public init(_ type: TextField.Props.KeyboardType) {
    switch type {
    case .default:
      self = .default
    case .asciiCapable:
      self = .asciiCapable
    case .numbersAndPunctuation:
      self = .numbersAndPunctuation
    case .URL:
      self = .URL
    case .numberPad:
      self = .numberPad
    case .phonePad:
      self = .phonePad
    case .namePhonePad:
      self = .namePhonePad
    case .emailAddress:
      self = .emailAddress
    case .decimalPad:
      self = .decimalPad
    case .twitter:
      self = .twitter
    case .webSearch:
      self = .webSearch
    case .asciiCapableNumberPad:
      self = .asciiCapableNumberPad
    }
  }
}

extension UIKeyboardAppearance {
  public init(_ type: TextField.Props.KeyboardAppearance) {
    switch type {
    case .default:
      self = .default
    case .dark:
      self = .dark
    case .light:
      self = .light
    }
  }
}

extension UIReturnKeyType {
  public init(_ type: TextField.Props.ReturnKeyType) {
    switch type {
    case .default:
      self = .default
    case .go:
      self = .go
    case .google:
      self = .google
    case .join:
      self = .join
    case .next:
      self = .next
    case .route:
      self = .route
    case .search:
      self = .search
    case .send:
      self = .send
    case .yahoo:
      self = .yahoo
    case .done:
      self = .done
    case .emergencyCall:
      self = .emergencyCall
    case .continue:
      self = .continue
    }
  }
}

extension UITextField.BorderStyle {
  public init(_ style: TextField.Props.BorderStyle) {
    switch style {
    case .none:
      self = .none
    case .line:
      self = .line
    case .bezel:
      self = .bezel
    case .roundedRect:
      self = .roundedRect
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
  public typealias RefTarget = UITextField

  static func update(valueBox: ValueControlBox<TokamakTextField>,
                     _ props: TextField.Props,
                     _ children: Null) {
    let control = valueBox.view
    control.textColor = UIColor(props.textColor)
    control.textAlignment = NSTextAlignment(props.textAlignment)
    control.placeholder = props.placeholder
    control.clearsOnBeginEditing = props.clearsOnBeginEditing
    control.clearsOnInsertion = props.clearsOnInsertion
    control.clearButtonMode = UITextField.ViewMode(props.clearButtonMode)
    control.autocapitalizationType =
      UITextAutocapitalizationType(props.autocapitalizationType)
    control.autocorrectionType =
      UITextAutocorrectionType(props.autocorrectionType)
    control.spellCheckingType =
      UITextSpellCheckingType(props.spellCheckingType)
    control.keyboardType = UIKeyboardType(props.keyboardType)
    control.keyboardAppearance = UIKeyboardAppearance(props.keyboardAppearance)
    control.returnKeyType = UIReturnKeyType(props.returnKeyType)
    control.borderStyle = UITextField.BorderStyle(props.borderStyle)
    control.isSecureTextEntry = props.isSecureTextEntry
  }

  static var valueChangeEvent: Event {
    return .editingChanged
  }
}

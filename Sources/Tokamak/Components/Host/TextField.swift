//
//  TextField.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 2/22/19.
//

public struct TextField: HostComponent {
  public struct Props: Equatable, ControlProps, StyleProps,
    ValueControlProps {
    public enum ViewMode {
      case never
      case whileEditing
      case unlessEditing
      case always
    }

    public enum TextAutocapitalizationType {
      case none
      case words
      case sentences
      case allCharacters
    }

    public enum TextAutocorrectionType {
      case `default`
      case no
      case yes
    }

    public enum TextSpellCheckingType {
      case `default`
      case no
      case yes
    }

    public enum KeyboardType {
      case `default`
      case asciiCapable
      case numbersAndPunctuation
      case URL
      case numberPad
      case phonePad
      case namePhonePad
      case emailAddress
      case decimalPad
      case twitter
      case webSearch
      case asciiCapableNumberPad
    }

    public let autocapitalizationType: TextAutocapitalizationType
    public let autocorrectionType: TextAutocorrectionType
    public let borderStyle: Style?
    public let clearButtonMode: ViewMode
    public let clearsOnBeginEditing: Bool
    public let clearsOnInsertion: Bool
    public let handlers: EventHandlers
    public let style: Style?
    public let value: String
    public let valueHandler: Handler<String>?
    public let isEnabled: Bool
    public let keyboardType: KeyboardType
    public let placeholder: String?
    public let spellCheckingType: TextSpellCheckingType
    public let textAlignment: TextAlignment
    public let textColor: Color
    public let isAnimated: Bool

    public init(
      _ style: Style? = nil,
      autocapitalizationType: TextAutocapitalizationType =
        TextAutocapitalizationType.sentences,
      autocorrectionType: TextAutocorrectionType =
        TextAutocorrectionType.default,
      borderStyle: Style? = nil,
      clearButtonMode: ViewMode = .never,
      clearsOnBeginEditing: Bool = false,
      clearsOnInsertion: Bool = false,
      handlers: EventHandlers = [:],
      isAnimated: Bool = true,
      isEnabled: Bool = true,
      keyboardType: KeyboardType = KeyboardType.default,
      placeholder: String? = nil,
      spellCheckingType: TextSpellCheckingType =
        TextSpellCheckingType.default,
      textAlignment: TextAlignment = TextAlignment.natural,
      textColor: Color = .black,
      value: String,
      valueHandler: Handler<String>? = nil
    ) {
      self.autocapitalizationType = autocapitalizationType
      self.autocorrectionType = autocorrectionType
      self.borderStyle = borderStyle
      self.clearButtonMode = clearButtonMode
      self.clearsOnBeginEditing = clearsOnBeginEditing
      self.clearsOnInsertion = clearsOnInsertion
      self.handlers = handlers
      self.style = style
      self.value = value
      self.valueHandler = valueHandler
      self.isEnabled = isEnabled
      self.keyboardType = keyboardType
      self.placeholder = placeholder
      self.spellCheckingType = spellCheckingType
      self.textAlignment = textAlignment
      self.textColor = textColor
      self.isAnimated = isAnimated
    }
  }

  public typealias Children = Null
}

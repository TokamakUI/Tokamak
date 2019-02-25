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

    public enum KeyboardAppearance {
      case `default`
      case dark
      case light
    }

    public enum ReturnKeyType {
      case `default`
      case go
      case google
      case join
      case next
      case route
      case search
      case send
      case yahoo
      case done
      case emergencyCall
      case `continue`
    }

    public enum BorderStyle {
      case none
      case line
      case bezel
      case roundedRect
    }

    public let autocapitalizationType: TextAutocapitalizationType
    public let autocorrectionType: TextAutocorrectionType
    public let borderStyle: BorderStyle
    public let clearButtonMode: ViewMode
    public let clearsOnBeginEditing: Bool
    public let clearsOnInsertion: Bool
    public let handlers: EventHandlers
    public let style: Style?
    public let value: String
    public let valueHandler: Handler<String>?
    public let isEnabled: Bool
    public let isSecureTextEntry: Bool
    public let keyboardAppearance: KeyboardAppearance
    public let keyboardType: KeyboardType
    public let placeholder: String?
    public let returnKeyType: ReturnKeyType
    public let spellCheckingType: TextSpellCheckingType
    public let textAlignment: TextAlignment
    public let textColor: Color
    public let isAnimated: Bool

    public init(
      _ style: Style? = nil,
      autocapitalizationType: TextAutocapitalizationType = .sentences,
      autocorrectionType: TextAutocorrectionType = .default,
      borderStyle: BorderStyle = .bezel,
      clearButtonMode: ViewMode = .never,
      clearsOnBeginEditing: Bool = false,
      clearsOnInsertion: Bool = false,
      handlers: EventHandlers = [:],
      isAnimated: Bool = true,
      isEnabled: Bool = true,
      isSecureTextEntry: Bool = false,
      keyboardAppearance: KeyboardAppearance = .default,
      keyboardType: KeyboardType = .default,
      placeholder: String? = nil,
      returnKeyType: ReturnKeyType = .default,
      spellCheckingType: TextSpellCheckingType = .default,
      textAlignment: TextAlignment = .natural,
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
      self.isSecureTextEntry = isSecureTextEntry
      self.isEnabled = isEnabled
      self.keyboardAppearance = keyboardAppearance
      self.keyboardType = keyboardType
      self.placeholder = placeholder
      self.returnKeyType = returnKeyType
      self.spellCheckingType = spellCheckingType
      self.textAlignment = textAlignment
      self.textColor = textColor
      self.isAnimated = isAnimated
    }
  }

  public typealias Children = Null
}

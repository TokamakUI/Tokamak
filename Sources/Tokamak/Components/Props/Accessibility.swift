//
//  Accessibility.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 2/21/19.
//

public struct Accessibility: Equatable {
  public let identifier: String?
  public let language: String?
  public let label: String?
  public let hint: String?
  public let value: String?
  public let elementsHidden: Bool
  public let isModal: Bool

  public init(
    elementsHidden: Bool = false,
    hint: String? = nil,
    isModal: Bool = false,
    label: String? = "",
    language: String? = nil,
    value: String? = "",
    identifier: String? = ""
  ) {
    self.elementsHidden = elementsHidden
    self.hint = hint
    self.isModal = isModal
    self.label = label
    self.language = language
    self.value = value
    self.identifier = identifier
  }
}

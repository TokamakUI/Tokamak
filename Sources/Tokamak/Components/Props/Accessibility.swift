//
//  Accessibility.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 2/21/19.
//

public struct Accessibility: Equatable {
  public let identifier: String?
  //    public let language: String?
  //    public let label: String?
  //    public let hint: String?
  //    public let value: String?
  //    public let elementsHidden: Bool // default value `false`
  //    public let isModal: Bool // default value `false`

  public init(
    identifier: String? = ""
    //     language: String?,
    //     label: String?,
    //     hint: String?,
    //     value: String?,
    //     elementsHidden: Bool = false, // default value `false`
    //     isModal: Bool // default value `false`
  ) {
    self.identifier = identifier
  }
}

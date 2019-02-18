//
//  TabItem.swift
//  Tokamak
//
//  Created by Max Desiatov on 04/02/2019.
//

public struct TabItem: Equatable {
  public let title: String?

  public init(title: String? = nil) {
    self.title = title
  }
}

//
//  Label.swift
//  Gluon
//
//  Created by Max Desiatov on 02/12/2018.
//

public struct Label: HostComponent {
  public struct Props: Equatable {
    public let alignment: TextAlignment

    public init(alignment: TextAlignment = .natural) {
      self.alignment = alignment
    }
  }

  public typealias Children = String
}

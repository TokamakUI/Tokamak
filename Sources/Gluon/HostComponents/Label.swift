//
//  Label.swift
//  Gluon
//
//  Created by Max Desiatov on 02/12/2018.
//

public struct LabelProps: Equatable {
  public let alignment: TextAlignment

  public init(alignment: TextAlignment = .natural) {
    self.alignment = alignment
  }
}

public struct Label: HostComponent {
  public typealias Props = LabelProps
  public typealias Children = String
}

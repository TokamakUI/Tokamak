//
//  View.swift
//  Gluon
//
//  Created by Max Desiatov on 29/12/2018.
//

public struct View: HostComponent {
  public typealias Children = [Node]

  public let props: Props
  public let children: [Node]

  public struct Props: Equatable {}
}

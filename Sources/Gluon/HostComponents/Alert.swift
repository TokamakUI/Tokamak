//
//  Alert.swift
//  Gluon
//
//  Created by Max Desiatov on 31/12/2018.
//

public struct Alert: HostComponent {
  public struct Props: Equatable {
    let title: String?
    let message: String?
  }

  public typealias Children = [Node]
}

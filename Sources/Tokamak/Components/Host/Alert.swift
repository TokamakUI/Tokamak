//
//  Alert.swift
//  Tokamak
//
//  Created by Max Desiatov on 31/12/2018.
//

struct Alert: HostComponent {
  struct Props: Equatable {
    let title: String?
    let message: String?
  }

  typealias Children = [AnyNode]
}

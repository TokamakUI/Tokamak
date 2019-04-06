//
//  TestProps.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 4/2/19.
//
//  TokamakLintTests testPropsIsEquatable test use this file

import Tokamak

struct ComponentWithEquatableProps: HostComponent {
  struct Props: Equatable {
    let title: String?
    let message: String?
  }
}

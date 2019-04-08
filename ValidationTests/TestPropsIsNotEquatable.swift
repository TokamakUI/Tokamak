//
//  TestPropsNotEquatable.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 4/2/19.
//
//  TokamakLintTests testPropsIsNotEquatable test use this file

import Tokamak

struct ComponentWithNotEquatableProps: HostComponent {
  struct Props {
    let title: String?
    let message: String?
  }
}

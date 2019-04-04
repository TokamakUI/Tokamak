//
//  TestProps.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 4/2/19.
//
// TokamakLintTests testPropsIsEquatable test use this file

import Foundation

public protocol Default {
  var str: String { get }
}

struct Props: Equatable, Default {
  var str: String
}

//
//  Default.swift
//  Tokamak
//
//  Created by Max Desiatov on 16/11/2018.
//

public protocol Default {
  associatedtype DefaultValue
  static var defaultValue: DefaultValue { get }
}

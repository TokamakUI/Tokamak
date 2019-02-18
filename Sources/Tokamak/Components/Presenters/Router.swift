//
//  Router.swift
//  Tokamak
//
//  Created by Max Desiatov on 03/01/2019.
//

public protocol Router {
  associatedtype Props: Equatable
  associatedtype Route: Equatable
}

//
//  View.swift
//
//
//  Created by Max Desiatov on 07/04/2020.
//

public protocol View {
  associatedtype Body: View

  var body: Self.Body { get }
}

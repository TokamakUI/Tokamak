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

extension Never: View {
  public typealias Body = Never
}

public extension View where Body == Never {
  var body: Never { fatalError() }
}

protocol ParentView {
  var children: [AnyView] { get }
}

protocol GroupView: ParentView {}

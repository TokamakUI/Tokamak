//
//  File.swift
//
//
//  Created by Carson Katri on 2/15/22.
//

/// An output from a `Renderer`.
public protocol Element: AnyObject {
  associatedtype Data: ElementData
  var data: Data { get }
  init(from data: Data)
  func update(with data: Data)
}

/// The data used to create an `Element`. We re-use `Element` instances, but can re-create and copy `ElementData` as often as needed.
public protocol ElementData: Equatable {
  init<V: View>(from primitiveView: V)
}

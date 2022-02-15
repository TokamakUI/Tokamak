//
//  File.swift
//
//
//  Created by Carson Katri on 2/3/22.
//

public protocol ViewVisitor {
  func visit<V: View>(_ view: V)
}

public extension View {
  func _visitChildren<V: ViewVisitor>(_ visitor: V) {
    visitor.visit(body)
  }
}

typealias ViewVisitorF<V: ViewVisitor> = (V) -> ()

protocol ViewReducer {
  associatedtype Result
  static func reduce<V: View>(into partialResult: inout Result, nextView: V)
  static func reduce<V: View>(partialResult: Result, nextView: V) -> Result
}

extension ViewReducer {
  static func reduce<V: View>(into partialResult: inout Result, nextView: V) {
    partialResult = Self.reduce(partialResult: partialResult, nextView: nextView)
  }

  static func reduce<V: View>(partialResult: Result, nextView: V) -> Result {
    var result = partialResult
    Self.reduce(into: &result, nextView: nextView)
    return result
  }
}

final class ReducerVisitor<R: ViewReducer>: ViewVisitor {
  var result: R.Result

  init(initialResult: R.Result) {
    result = initialResult
  }

  func visit<V>(_ view: V) where V: View {
    R.reduce(into: &result, nextView: view)
  }
}

extension ViewReducer {
  typealias Visitor = ReducerVisitor<Self>
}

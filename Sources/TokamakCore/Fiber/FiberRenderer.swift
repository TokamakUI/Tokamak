//
//  File.swift
//
//
//  Created by Carson Katri on 2/15/22.
//

public protocol FiberRenderer {
  associatedtype ElementType: Element
  static func isPrimitive<V>(_ view: V) -> Bool where V: View
  func commit(_ mutations: [Mutation<Self>])
  var rootElement: ElementType { get }
  var defaultEnvironment: EnvironmentValues { get }
}

public extension FiberRenderer {
  var defaultEnvironment: EnvironmentValues { .init() }

  @discardableResult
  func render<V: View>(_ view: V) -> FiberReconciler<Self> {
    .init(self, view)
  }
}

//
//  File.swift
//
//
//  Created by Carson Katri on 2/15/22.
//

/// A renderer capable of performing mutations specified by a `FiberReconciler`.
public protocol FiberRenderer {
  /// The element class this renderer uses.
  associatedtype ElementType: Element
  /// Check whether a `View` is a primitive for this renderer.
  static func isPrimitive<V>(_ view: V) -> Bool where V: View
  /// Apply the mutations to the elements.
  func commit(_ mutations: [Mutation<Self>])
  /// The root element all top level views should be mounted on.
  var rootElement: ElementType { get }
  /// The smallest set of initial `EnvironmentValues` needed for this renderer to function.
  var defaultEnvironment: EnvironmentValues { get }
}

public extension FiberRenderer {
  var defaultEnvironment: EnvironmentValues { .init() }

  @discardableResult
  func render<V: View>(_ view: V) -> FiberReconciler<Self> {
    .init(self, view)
  }
}

//
//  File.swift
//
//
//  Created by Carson Katri on 2/15/22.
//

import Foundation

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
  /// The size of the window we are rendering in.
  var sceneSize: CGSize { get }
  /// Calculate the size of `Text` in `environment` for layout.
  func measureText(_ text: Text, proposedSize: CGSize, in environment: EnvironmentValues) -> CGSize
}

public extension FiberRenderer {
  var defaultEnvironment: EnvironmentValues { .init() }

  @discardableResult
  func render<V: View>(_ view: V) -> FiberReconciler<Self> {
    .init(self, view)
  }
}

extension EnvironmentValues {
  private enum MeasureTextKey: EnvironmentKey {
    static var defaultValue: (Text, CGSize, EnvironmentValues) -> CGSize {
      { _, _, _ in .zero }
    }
  }

  var measureText: (Text, CGSize, EnvironmentValues) -> CGSize {
    get { self[MeasureTextKey.self] }
    set { self[MeasureTextKey.self] = newValue }
  }
}

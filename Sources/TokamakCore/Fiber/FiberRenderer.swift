// Copyright 2022 Tokamak contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Created by Carson Katri on 2/15/22.
//

import Foundation

/// A renderer capable of performing mutations specified by a `FiberReconciler`.
public protocol FiberRenderer {
  /// The element class this renderer uses.
  associatedtype ElementType: FiberElement
  /// Check whether a `View` is a primitive for this renderer.
  static func isPrimitive<V>(_ view: V) -> Bool where V: View
  func visitPrimitiveChildren<Primitive, Visitor>(
    _ view: Primitive
  ) -> ViewVisitorF<Visitor>? where Primitive: View, Visitor: ViewVisitor
  /// Apply the mutations to the elements.
  func commit(_ mutations: [Mutation<Self>])
  /// The root element all top level views should be mounted on.
  var rootElement: ElementType { get }
  /// The smallest set of initial `EnvironmentValues` needed for this renderer to function.
  var defaultEnvironment: EnvironmentValues { get }
  /// The size of the window we are rendering in.
  var sceneSize: CGSize { get }
  /// Whether layout is enabled for this renderer.
  var useDynamicLayout: Bool { get }
  /// Calculate the size of `Text` in `environment` for layout.
  func measureText(_ text: Text, proposedSize: CGSize, in environment: EnvironmentValues) -> CGSize
}

public extension FiberRenderer {
  var defaultEnvironment: EnvironmentValues { .init() }

  func visitPrimitiveChildren<Primitive, Visitor>(
    _ view: Primitive
  ) -> ViewVisitorF<Visitor>? where Primitive: View, Visitor: ViewVisitor {
    nil
  }

  func viewVisitor<V: View, Visitor: ViewVisitor>(for view: V) -> ViewVisitorF<Visitor> {
    if Self.isPrimitive(view) {
      return visitPrimitiveChildren(view) ?? view._visitChildren
    } else {
      return view._visitChildren
    }
  }

  @discardableResult
  func render<V: View>(_ view: V) -> FiberReconciler<Self> {
    .init(self, view)
  }

  @discardableResult
  func render<A: App>(_ app: A) -> FiberReconciler<Self> {
    .init(self, app)
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

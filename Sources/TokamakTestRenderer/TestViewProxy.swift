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
//  Created by Carson Katri on 6/30/22.
//

import Foundation

@_spi(TokamakCore)
import TokamakCore

/// A proxy for an identified view in the `TestFiberRenderer`.
///
/// The properties are evaluated on access,
/// so you will never unintentionally access an `alternate` value.
@dynamicMemberLookup
public struct TestViewProxy<V: View> {
  /// The id to lookup.
  let id: AnyHashable

  /// The active reconciler instance to search in.
  let reconciler: FiberReconciler<TestFiberRenderer>

  /// Searches for a `Fiber` representing `id`.
  ///
  /// - Note: This returns the child of the `identified(by:)` modifier,
  ///         not the `IdentifiedView` itself.
  @_spi(TokamakCore)
  public var fiber: FiberReconciler<TestFiberRenderer>.Fiber? {
    let id = AnyHashable(id)
    let result = TokamakCore.walk(
      reconciler.current
    ) { fiber -> WalkWorkResult<FiberReconciler<TestFiberRenderer>.Fiber?> in
      guard case let .view(view, _) = fiber.content,
            !(view is AnyOptional),
            (view as? IdentifiedViewProtocol)?.id == AnyHashable(id),
            let child = fiber.child
      else { return WalkWorkResult.continue }
      return WalkWorkResult.break(with: child)
    }
    guard case let .success(fiber) = result else { return nil }
    return fiber
  }

  /// The `fiber`'s content casted to `V`.
  public var view: V? {
    guard case let .view(view, _) = fiber?.content else { return nil }
    return view as? V
  }

  /// Access properties from the `view` without specifying `.view` manually.
  public subscript<T>(dynamicMember member: KeyPath<V, T>) -> T? {
    self.view?[keyPath: member]
  }
}

/// An erased `IdentifiedView`.
protocol IdentifiedViewProtocol {
  var id: AnyHashable { get }
}

/// A wrapper that identifies a `View` in a test.
struct IdentifiedView<Content: View>: View, IdentifiedViewProtocol {
  let id: AnyHashable
  let content: Content

  var body: some View {
    content
  }
}

public extension View {
  /// Identifies a `View` in a test.
  ///
  /// You can access this view from the `FiberReconciler` with `findView(id:as:)`.
  func identified<ID: Hashable>(by id: ID) -> some View {
    IdentifiedView(id: id, content: self)
  }
}

public extension FiberReconciler where Renderer == TestFiberRenderer {
  /// Find the `View` identified by `ID`.
  ///
  /// - Note: This returns a proxy to the child of the `identified(by:)` modifier,
  ///         not the `IdentifiedView` itself.
  func findView<ID: Hashable, V: View>(
    id: ID,
    as type: V.Type = V.self
  ) -> TestViewProxy<V> {
    TestViewProxy<V>(id: id, reconciler: self)
  }
}

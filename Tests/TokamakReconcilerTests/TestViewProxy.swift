// Copyright 2021 Tokamak contributors
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
//  Created by Carson Katri on 6/29/22.
//

@_spi(TokamakCore)
import TokamakCore

import TokamakTestRenderer

import Dispatch

@dynamicMemberLookup
struct TestViewProxy<V: View> {
  let id: AnyHashable
  let reconciler: FiberReconciler<TestFiberRenderer>
  var fiber: FiberReconciler<TestFiberRenderer>.Fiber? {
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

  var view: V? {
    guard case let .view(view, _) = fiber?.content else { return nil }
    return view as? V
  }

  subscript<T>(dynamicMember member: KeyPath<V, T>) -> T? {
    self.view?[keyPath: member]
  }
}

protocol IdentifiedViewProtocol {
  var id: AnyHashable { get }
}

struct IdentifiedView<Content: View>: View, IdentifiedViewProtocol {
  let id: AnyHashable
  let content: Content

  var body: some View {
    content
  }
}

extension View {
  func identified<ID: Hashable>(by id: ID) -> some View {
    IdentifiedView(id: id, content: self)
  }
}

extension FiberReconciler where Renderer == TestFiberRenderer {
  func findView<ID: Hashable, V: View>(
    id: ID,
    as type: V.Type = V.self
  ) -> TestViewProxy<V> {
    TestViewProxy<V>(id: id, reconciler: self)
  }

  /// Wait for the scheduled action to complete.
  func turnRunLoop() {
    renderer.workItem.workItem?.wait()
    renderer.workItem.workItem = nil
  }
}

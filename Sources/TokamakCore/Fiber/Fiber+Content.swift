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
//  Created by Carson Katri on 5/31/22.
//

import Foundation

public extension FiberReconciler.Fiber {
  enum Content {
    /// The underlying `App` instance and a function to visit it generically.
    case app(Any, visit: (AppVisitor) -> ())
    /// The underlying `Scene` instance and a function to visit it generically.
    case scene(Any, visit: (SceneVisitor) -> ())
    /// The underlying `View` instance and a function to visit it generically.
    case view(Any, visit: (ViewVisitor) -> ())
  }

  /// Create a `Content` value for a given `App`.
  func content<A: App>(for app: A) -> Content {
    .app(
      app,
      visit: { [weak self] in
        guard case let .app(app, _) = self?.content else { return }
        // swiftlint:disable:next force_cast
        $0.visit(app as! A)
      }
    )
  }

  /// Create a `Content` value for a given `Scene`.
  func content<S: Scene>(for scene: S) -> Content {
    .scene(
      scene,
      visit: { [weak self] in
        guard case let .scene(scene, _) = self?.content else { return }
        // swiftlint:disable:next force_cast
        $0.visit(scene as! S)
      }
    )
  }

  /// Create a `Content` value for a given `View`.
  func content<V: View>(for view: V) -> Content {
    .view(
      view,
      visit: { [weak self] in
        guard case let .view(view, _) = self?.content else { return }
        // swiftlint:disable:next force_cast
        $0.visit(view as! V)
      }
    )
  }
}

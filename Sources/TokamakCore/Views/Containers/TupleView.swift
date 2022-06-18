// Copyright 2020 Tokamak contributors
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
//  Created by Max Desiatov on 08/04/2020.
//

/// A `View` created from a `Tuple` of `View` values.
///
/// Mainly for use with `@ViewBuilder`.
public struct TupleView<T>: _PrimitiveView {
  public let value: T

  let _children: [AnyView]
  private let visit: (ViewVisitor) -> ()

  public init(_ value: T) {
    self.value = value
    _children = []
    visit = { _ in }
  }

  public init(_ value: T, children: [AnyView]) {
    self.value = value
    _children = children
    visit = {
      for child in children {
        $0.visit(child)
      }
    }
  }

  public func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    visit(visitor)
  }

  init<T1: View, T2: View>(_ v1: T1, _ v2: T2) where T == (T1, T2) {
    value = (v1, v2)
    _children = [AnyView(v1), AnyView(v2)]
    visit = {
      $0.visit(v1)
      $0.visit(v2)
    }
  }

  // swiftlint:disable large_tuple
  init<T1: View, T2: View, T3: View>(_ v1: T1, _ v2: T2, _ v3: T3) where T == (T1, T2, T3) {
    value = (v1, v2, v3)
    _children = [AnyView(v1), AnyView(v2), AnyView(v3)]
    visit = {
      $0.visit(v1)
      $0.visit(v2)
      $0.visit(v3)
    }
  }

  init<T1: View, T2: View, T3: View, T4: View>(_ v1: T1, _ v2: T2, _ v3: T3, _ v4: T4)
    where T == (T1, T2, T3, T4)
  {
    value = (v1, v2, v3, v4)
    _children = [AnyView(v1), AnyView(v2), AnyView(v3), AnyView(v4)]
    visit = {
      $0.visit(v1)
      $0.visit(v2)
      $0.visit(v3)
      $0.visit(v4)
    }
  }

  init<T1: View, T2: View, T3: View, T4: View, T5: View>(
    _ v1: T1,
    _ v2: T2,
    _ v3: T3,
    _ v4: T4,
    _ v5: T5
  ) where T == (T1, T2, T3, T4, T5) {
    value = (v1, v2, v3, v4, v5)
    _children = [AnyView(v1), AnyView(v2), AnyView(v3), AnyView(v4), AnyView(v5)]
    visit = {
      $0.visit(v1)
      $0.visit(v2)
      $0.visit(v3)
      $0.visit(v4)
      $0.visit(v5)
    }
  }

  init<T1: View, T2: View, T3: View, T4: View, T5: View, T6: View>(
    _ v1: T1,
    _ v2: T2,
    _ v3: T3,
    _ v4: T4,
    _ v5: T5,
    _ v6: T6
  ) where T == (T1, T2, T3, T4, T5, T6) {
    value = (v1, v2, v3, v4, v5, v6)
    _children = [AnyView(v1), AnyView(v2), AnyView(v3), AnyView(v4), AnyView(v5), AnyView(v6)]
    visit = {
      $0.visit(v1)
      $0.visit(v2)
      $0.visit(v3)
      $0.visit(v4)
      $0.visit(v5)
      $0.visit(v6)
    }
  }

  init<T1: View, T2: View, T3: View, T4: View, T5: View, T6: View, T7: View>(
    _ v1: T1,
    _ v2: T2,
    _ v3: T3,
    _ v4: T4,
    _ v5: T5,
    _ v6: T6,
    _ v7: T7
  ) where T == (T1, T2, T3, T4, T5, T6, T7) {
    value = (v1, v2, v3, v4, v5, v6, v7)
    _children = [
      AnyView(v1),
      AnyView(v2),
      AnyView(v3),
      AnyView(v4),
      AnyView(v5),
      AnyView(v6),
      AnyView(v7),
    ]
    visit = {
      $0.visit(v1)
      $0.visit(v2)
      $0.visit(v3)
      $0.visit(v4)
      $0.visit(v5)
      $0.visit(v6)
      $0.visit(v7)
    }
  }

  init<T1: View, T2: View, T3: View, T4: View, T5: View, T6: View, T7: View, T8: View>(
    _ v1: T1,
    _ v2: T2,
    _ v3: T3,
    _ v4: T4,
    _ v5: T5,
    _ v6: T6,
    _ v7: T7,
    _ v8: T8
  ) where T == (T1, T2, T3, T4, T5, T6, T7, T8) {
    value = (v1, v2, v3, v4, v5, v6, v7, v8)
    _children = [
      AnyView(v1),
      AnyView(v2),
      AnyView(v3),
      AnyView(v4),
      AnyView(v5),
      AnyView(v6),
      AnyView(v7),
      AnyView(v8),
    ]
    visit = {
      $0.visit(v1)
      $0.visit(v2)
      $0.visit(v3)
      $0.visit(v4)
      $0.visit(v5)
      $0.visit(v6)
      $0.visit(v7)
      $0.visit(v8)
    }
  }

  init<T1: View, T2: View, T3: View, T4: View, T5: View, T6: View, T7: View, T8: View, T9: View>(
    _ v1: T1,
    _ v2: T2,
    _ v3: T3,
    _ v4: T4,
    _ v5: T5,
    _ v6: T6,
    _ v7: T7,
    _ v8: T8,
    _ v9: T9
  ) where T == (T1, T2, T3, T4, T5, T6, T7, T8, T9) {
    value = (v1, v2, v3, v4, v5, v6, v7, v8, v9)
    _children = [
      AnyView(v1),
      AnyView(v2),
      AnyView(v3),
      AnyView(v4),
      AnyView(v5),
      AnyView(v6),
      AnyView(v7),
      AnyView(v8),
      AnyView(v9),
    ]
    visit = {
      $0.visit(v1)
      $0.visit(v2)
      $0.visit(v3)
      $0.visit(v4)
      $0.visit(v5)
      $0.visit(v6)
      $0.visit(v7)
      $0.visit(v8)
      $0.visit(v9)
    }
  }

  init<
    T1: View,
    T2: View,
    T3: View,
    T4: View,
    T5: View,
    T6: View,
    T7: View,
    T8: View,
    T9: View,
    T10: View
  >(
    _ v1: T1,
    _ v2: T2,
    _ v3: T3,
    _ v4: T4,
    _ v5: T5,
    _ v6: T6,
    _ v7: T7,
    _ v8: T8,
    _ v9: T9,
    _ v10: T10
  ) where T == (T1, T2, T3, T4, T5, T6, T7, T8, T9, T10) {
    value = (v1, v2, v3, v4, v5, v6, v7, v8, v9, v10)
    _children = [
      AnyView(v1),
      AnyView(v2),
      AnyView(v3),
      AnyView(v4),
      AnyView(v5),
      AnyView(v6),
      AnyView(v7),
      AnyView(v8),
      AnyView(v9),
      AnyView(v10),
    ]
    visit = {
      $0.visit(v1)
      $0.visit(v2)
      $0.visit(v3)
      $0.visit(v4)
      $0.visit(v5)
      $0.visit(v6)
      $0.visit(v7)
      $0.visit(v8)
      $0.visit(v9)
      $0.visit(v10)
    }
  }
}

extension TupleView: GroupView {
  public var children: [AnyView] { _children }
}

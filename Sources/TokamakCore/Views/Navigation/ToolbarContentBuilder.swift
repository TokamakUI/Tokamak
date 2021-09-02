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
//  Created by Carson Katri on 7/7/20.
//

@resultBuilder
public enum ToolbarContentBuilder<ID> {
  public static func buildBlock<V>(_ content: ToolbarItem<ID, V>)
    -> ToolbarItemGroup<ID, ToolbarItem<ID, V>> where V: View
  {
    .init(content)
  }
}

// swiftlint:disable file_length
// swiftlint:disable large_tuple
// swiftlint:disable function_parameter_count

public extension ToolbarContentBuilder {
  static func buildBlock<C0, C1>(_ c0: ToolbarItem<ID, C0>,
                                 _ c1: ToolbarItem<ID, C1>) -> ToolbarItemGroup<
    ID,
    (ToolbarItem<ID, C0>, ToolbarItem<ID, C1>)
  >
    where C0: View, C1: View
  {
    .init(c0, c1)
  }
}

public extension ToolbarContentBuilder {
  static func buildBlock<C0, C1, C2>(_ c0: ToolbarItem<ID, C0>, _ c1: ToolbarItem<ID, C1>,
                                     _ c2: ToolbarItem<ID, C2>)
    -> ToolbarItemGroup<ID, (ToolbarItem<ID, C0>, ToolbarItem<ID, C1>, ToolbarItem<ID, C2>)>
    where C0: View, C1: View, C2: View
  {
    .init(c0, c1, c2)
  }
}

public extension ToolbarContentBuilder {
  static func buildBlock<C0, C1, C2, C3>(
    _ c0: ToolbarItem<ID, C0>,
    _ c1: ToolbarItem<ID, C1>,
    _ c2: ToolbarItem<ID, C2>,
    _ c3: ToolbarItem<ID, C3>
  )
    -> ToolbarItemGroup<
      ID,
      (ToolbarItem<ID, C0>, ToolbarItem<ID, C1>, ToolbarItem<ID, C2>, ToolbarItem<ID, C3>)
    >
    where C0: View, C1: View, C2: View, C3: View
  {
    .init(c0, c1, c2, c3)
  }
}

public extension ToolbarContentBuilder {
  static func buildBlock<C0, C1, C2, C3, C4>(
    _ c0: ToolbarItem<ID, C0>,
    _ c1: ToolbarItem<ID, C1>,
    _ c2: ToolbarItem<ID, C2>,
    _ c3: ToolbarItem<ID, C3>,
    _ c4: ToolbarItem<ID, C4>
  ) -> ToolbarItemGroup<ID, (
    ToolbarItem<ID, C0>,
    ToolbarItem<ID, C1>,
    ToolbarItem<ID, C2>,
    ToolbarItem<ID, C3>,
    ToolbarItem<ID, C4>
  )> where C0: View, C1: View, C2: View, C3: View, C4: View {
    .init(c0, c1, c2, c3, c4)
  }
}

public extension ToolbarContentBuilder {
  static func buildBlock<C0, C1, C2, C3, C4, C5>(
    _ c0: ToolbarItem<ID, C0>,
    _ c1: ToolbarItem<ID, C1>,
    _ c2: ToolbarItem<ID, C2>,
    _ c3: ToolbarItem<ID, C3>,
    _ c4: ToolbarItem<ID, C4>,
    _ c5: ToolbarItem<ID, C5>
  ) -> ToolbarItemGroup<ID, (
    ToolbarItem<ID, C0>,
    ToolbarItem<ID, C1>,
    ToolbarItem<ID, C2>,
    ToolbarItem<ID, C3>,
    ToolbarItem<ID, C4>,
    ToolbarItem<ID, C5>
  )> where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View {
    .init(c0, c1, c2, c3, c4, c5)
  }
}

public extension ToolbarContentBuilder {
  static func buildBlock<C0, C1, C2, C3, C4, C5, C6>(
    _ c0: ToolbarItem<ID, C0>,
    _ c1: ToolbarItem<ID, C1>,
    _ c2: ToolbarItem<ID, C2>,
    _ c3: ToolbarItem<ID, C3>,
    _ c4: ToolbarItem<ID, C4>,
    _ c5: ToolbarItem<ID, C5>,
    _ c6: ToolbarItem<ID, C6>
  ) -> ToolbarItemGroup<ID, (
    ToolbarItem<ID, C0>,
    ToolbarItem<ID, C1>,
    ToolbarItem<ID, C2>,
    ToolbarItem<ID, C3>,
    ToolbarItem<ID, C4>,
    ToolbarItem<ID, C5>,
    ToolbarItem<ID, C6>
  )> where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View {
    .init(c0, c1, c2, c3, c4, c5, c6)
  }
}

public extension ToolbarContentBuilder {
  static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7>(
    _ c0: ToolbarItem<ID, C0>,
    _ c1: ToolbarItem<ID, C1>,
    _ c2: ToolbarItem<ID, C2>,
    _ c3: ToolbarItem<ID, C3>,
    _ c4: ToolbarItem<ID, C4>,
    _ c5: ToolbarItem<ID, C5>,
    _ c6: ToolbarItem<ID, C6>,
    _ c7: ToolbarItem<ID, C7>
  ) -> ToolbarItemGroup<ID, (
    ToolbarItem<ID, C0>,
    ToolbarItem<ID, C1>,
    ToolbarItem<ID, C2>,
    ToolbarItem<ID, C3>,
    ToolbarItem<ID, C4>,
    ToolbarItem<ID, C5>,
    ToolbarItem<ID, C6>,
    ToolbarItem<ID, C7>
  )> where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View {
    .init(c0, c1, c2, c3, c4, c5, c6, c7)
  }
}

public extension ToolbarContentBuilder {
  static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8>(
    _ c0: ToolbarItem<ID, C0>,
    _ c1: ToolbarItem<ID, C1>,
    _ c2: ToolbarItem<ID, C2>,
    _ c3: ToolbarItem<ID, C3>,
    _ c4: ToolbarItem<ID, C4>,
    _ c5: ToolbarItem<ID, C5>,
    _ c6: ToolbarItem<ID, C6>,
    _ c7: ToolbarItem<ID, C7>,
    _ c8: ToolbarItem<ID, C8>
  ) -> ToolbarItemGroup<ID, (
    ToolbarItem<ID, C0>,
    ToolbarItem<ID, C1>,
    ToolbarItem<ID, C2>,
    ToolbarItem<ID, C3>,
    ToolbarItem<ID, C4>,
    ToolbarItem<ID, C5>,
    ToolbarItem<ID, C6>,
    ToolbarItem<ID, C7>,
    ToolbarItem<ID, C8>
  )> where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View,
    C8: View
  {
    .init(c0, c1, c2, c3, c4, c5, c6, c7, c8)
  }
}

public extension ToolbarContentBuilder {
  static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>(
    _ c0: ToolbarItem<ID, C0>,
    _ c1: ToolbarItem<ID, C1>,
    _ c2: ToolbarItem<ID, C2>,
    _ c3: ToolbarItem<ID, C3>,
    _ c4: ToolbarItem<ID, C4>,
    _ c5: ToolbarItem<ID, C5>,
    _ c6: ToolbarItem<ID, C6>,
    _ c7: ToolbarItem<ID, C7>,
    _ c8: ToolbarItem<ID, C8>,
    _ c9: ToolbarItem<ID, C9>
  ) -> ToolbarItemGroup<ID, (
    ToolbarItem<ID, C0>,
    ToolbarItem<ID, C1>,
    ToolbarItem<ID, C2>,
    ToolbarItem<ID, C3>,
    ToolbarItem<ID, C4>,
    ToolbarItem<ID, C5>,
    ToolbarItem<ID, C6>,
    ToolbarItem<ID, C7>,
    ToolbarItem<ID, C8>,
    ToolbarItem<ID, C9>
  )> where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View,
    C9: View
  {
    .init(c0, c1, c2, c3, c4, c5, c6, c7, c8, c9)
  }
}

extension ToolbarItemGroup: View {
  public var body: some View {
    let items = _items.sorted { a, b in
      if let a = a.view as? AnyToolbarItem,
         let b = b.view as? AnyToolbarItem
      {
        // Bring `.navigation` placements to the front
        if a.placement == .navigation && b.placement != .navigation {
          return true
        }
      }
      return false
    }
    return ForEach(Array(items.enumerated()), id: \.offset) { _, view in
      view
    }
  }

  public init(_ value: Items, children: [AnyView]) {
    items = value
    _items = children
  }

  init<T1: View>(_ v1: ToolbarItem<ID, T1>) where Items == ToolbarItem<ID, T1> {
    items = v1
    _items = [AnyView(v1)]
  }

  init<T1: View, T2: View>(_ v1: ToolbarItem<ID, T1>, _ v2: ToolbarItem<ID, T2>)
    where Items == (ToolbarItem<ID, T1>, ToolbarItem<ID, T2>)
  {
    items = (v1, v2)
    _items = [AnyView(v1), AnyView(v2)]
  }

  // swiftlint:disable large_tuple
  init<T1: View, T2: View, T3: View>(
    _ v1: ToolbarItem<ID, T1>,
    _ v2: ToolbarItem<ID, T2>,
    _ v3: ToolbarItem<ID, T3>
  ) where Items == (ToolbarItem<ID, T1>, ToolbarItem<ID, T2>, ToolbarItem<ID, T3>) {
    items = (v1, v2, v3)
    _items = [AnyView(v1), AnyView(v2), AnyView(v3)]
  }

  init<T1: View, T2: View, T3: View, T4: View>(
    _ v1: ToolbarItem<ID, T1>,
    _ v2: ToolbarItem<ID, T2>,
    _ v3: ToolbarItem<ID, T3>,
    _ v4: ToolbarItem<ID, T4>
  ) where Items == (
    ToolbarItem<ID, T1>,
    ToolbarItem<ID, T2>,
    ToolbarItem<ID, T3>,
    ToolbarItem<ID, T4>
  ) {
    items = (v1, v2, v3, v4)
    _items = [AnyView(v1), AnyView(v2), AnyView(v3), AnyView(v4)]
  }

  init<T1: View, T2: View, T3: View, T4: View, T5: View>(
    _ v1: ToolbarItem<ID, T1>,
    _ v2: ToolbarItem<ID, T2>,
    _ v3: ToolbarItem<ID, T3>,
    _ v4: ToolbarItem<ID, T4>,
    _ v5: ToolbarItem<ID, T5>
  ) where Items == (
    ToolbarItem<ID, T1>,
    ToolbarItem<ID, T2>,
    ToolbarItem<ID, T3>,
    ToolbarItem<ID, T4>,
    ToolbarItem<ID, T5>
  ) {
    items = (v1, v2, v3, v4, v5)
    _items = [AnyView(v1), AnyView(v2), AnyView(v3), AnyView(v4), AnyView(v5)]
  }

  init<T1: View, T2: View, T3: View, T4: View, T5: View, T6: View>(
    _ v1: ToolbarItem<ID, T1>,
    _ v2: ToolbarItem<ID, T2>,
    _ v3: ToolbarItem<ID, T3>,
    _ v4: ToolbarItem<ID, T4>,
    _ v5: ToolbarItem<ID, T5>,
    _ v6: ToolbarItem<ID, T6>
  ) where Items == (
    ToolbarItem<ID, T1>,
    ToolbarItem<ID, T2>,
    ToolbarItem<ID, T3>,
    ToolbarItem<ID, T4>,
    ToolbarItem<ID, T5>,
    ToolbarItem<ID, T6>
  ) {
    items = (v1, v2, v3, v4, v5, v6)
    _items = [AnyView(v1), AnyView(v2), AnyView(v3), AnyView(v4), AnyView(v5), AnyView(v6)]
  }

  init<T1: View, T2: View, T3: View, T4: View, T5: View, T6: View, T7: View>(
    _ v1: ToolbarItem<ID, T1>,
    _ v2: ToolbarItem<ID, T2>,
    _ v3: ToolbarItem<ID, T3>,
    _ v4: ToolbarItem<ID, T4>,
    _ v5: ToolbarItem<ID, T5>,
    _ v6: ToolbarItem<ID, T6>,
    _ v7: ToolbarItem<ID, T7>
  ) where Items == (
    ToolbarItem<ID, T1>,
    ToolbarItem<ID, T2>,
    ToolbarItem<ID, T3>,
    ToolbarItem<ID, T4>,
    ToolbarItem<ID, T5>,
    ToolbarItem<ID, T6>,
    ToolbarItem<ID, T7>
  ) {
    items = (v1, v2, v3, v4, v5, v6, v7)
    _items = [
      AnyView(v1),
      AnyView(v2),
      AnyView(v3),
      AnyView(v4),
      AnyView(v5),
      AnyView(v6),
      AnyView(v7),
    ]
  }

  init<T1: View, T2: View, T3: View, T4: View, T5: View, T6: View, T7: View, T8: View>(
    _ v1: ToolbarItem<ID, T1>,
    _ v2: ToolbarItem<ID, T2>,
    _ v3: ToolbarItem<ID, T3>,
    _ v4: ToolbarItem<ID, T4>,
    _ v5: ToolbarItem<ID, T5>,
    _ v6: ToolbarItem<ID, T6>,
    _ v7: ToolbarItem<ID, T7>,
    _ v8: ToolbarItem<ID, T8>
  ) where Items == (
    ToolbarItem<ID, T1>,
    ToolbarItem<ID, T2>,
    ToolbarItem<ID, T3>,
    ToolbarItem<ID, T4>,
    ToolbarItem<ID, T5>,
    ToolbarItem<ID, T6>,
    ToolbarItem<ID, T7>,
    ToolbarItem<ID, T8>
  ) {
    items = (v1, v2, v3, v4, v5, v6, v7, v8)
    _items = [
      AnyView(v1),
      AnyView(v2),
      AnyView(v3),
      AnyView(v4),
      AnyView(v5),
      AnyView(v6),
      AnyView(v7),
      AnyView(v8),
    ]
  }

  init<T1: View, T2: View, T3: View, T4: View, T5: View, T6: View, T7: View, T8: View, T9: View>(
    _ v1: ToolbarItem<ID, T1>,
    _ v2: ToolbarItem<ID, T2>,
    _ v3: ToolbarItem<ID, T3>,
    _ v4: ToolbarItem<ID, T4>,
    _ v5: ToolbarItem<ID, T5>,
    _ v6: ToolbarItem<ID, T6>,
    _ v7: ToolbarItem<ID, T7>,
    _ v8: ToolbarItem<ID, T8>,
    _ v9: ToolbarItem<ID, T9>
  ) where Items == (
    ToolbarItem<ID, T1>,
    ToolbarItem<ID, T2>,
    ToolbarItem<ID, T3>,
    ToolbarItem<ID, T4>,
    ToolbarItem<ID, T5>,
    ToolbarItem<ID, T6>,
    ToolbarItem<ID, T7>,
    ToolbarItem<ID, T8>,
    ToolbarItem<ID, T9>
  ) {
    items = (v1, v2, v3, v4, v5, v6, v7, v8, v9)
    _items = [
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
    _ v1: ToolbarItem<ID, T1>,
    _ v2: ToolbarItem<ID, T2>,
    _ v3: ToolbarItem<ID, T3>,
    _ v4: ToolbarItem<ID, T4>,
    _ v5: ToolbarItem<ID, T5>,
    _ v6: ToolbarItem<ID, T6>,
    _ v7: ToolbarItem<ID, T7>,
    _ v8: ToolbarItem<ID, T8>,
    _ v9: ToolbarItem<ID, T9>,
    _ v10: ToolbarItem<ID, T10>
  ) where Items == (
    ToolbarItem<ID, T1>,
    ToolbarItem<ID, T2>,
    ToolbarItem<ID, T3>,
    ToolbarItem<ID, T4>,
    ToolbarItem<ID, T5>,
    ToolbarItem<ID, T6>,
    ToolbarItem<ID, T7>,
    ToolbarItem<ID, T8>,
    ToolbarItem<ID, T9>,
    ToolbarItem<ID, T10>
  ) {
    items = (v1, v2, v3, v4, v5, v6, v7, v8, v9, v10)
    _items = [
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
  }
}

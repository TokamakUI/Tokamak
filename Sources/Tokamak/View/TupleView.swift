//
//  Created by Max Desiatov on 08/04/2020.
//

public struct TupleView<T>: View {
  public let value: T

  let children: [AnyView]

  public init(_ value: T) {
    self.value = value
    children = []
  }

  init<T1: View, T2: View>(_ v1: T1, _ v2: T2) where T == (T1, T2) {
    value = (v1, v2)
    children = [AnyView(v1), AnyView(v2)]
  }

  init<T1: View, T2: View, T3: View>(_ v1: T1, _ v2: T2, _ v3: T3) where T == (T1, T2, T3) {
    value = (v1, v2, v3)
    children = [AnyView(v1), AnyView(v2), AnyView(v3)]
  }

  // swiftlint:disable line_length
  // swiftlint:disable large_tuple
  init<T1: View, T2: View, T3: View, T4: View>(_ v1: T1, _ v2: T2, _ v3: T3, _ v4: T4) where T == (T1, T2, T3, T4) {
    value = (v1, v2, v3, v4)
    children = [AnyView(v1), AnyView(v2), AnyView(v3), AnyView(v4)]
  }

  init<T1: View, T2: View, T3: View, T4: View, T5: View>(_ v1: T1, _ v2: T2, _ v3: T3, _ v4: T4, _ v5: T5) where T == (T1, T2, T3, T4, T5) {
    value = (v1, v2, v3, v4, v5)
    children = [AnyView(v1), AnyView(v2), AnyView(v3), AnyView(v4), AnyView(v5)]
  }

  init<T1: View, T2: View, T3: View, T4: View, T5: View, T6: View>(_ v1: T1, _ v2: T2, _ v3: T3, _ v4: T4, _ v5: T5, _ v6: T6) where T == (T1, T2, T3, T4, T5, T6) {
    value = (v1, v2, v3, v4, v5, v6)
    children = [AnyView(v1), AnyView(v2), AnyView(v3), AnyView(v4), AnyView(v5), AnyView(v6)]
  }

  init<T1: View, T2: View, T3: View, T4: View, T5: View, T6: View, T7: View>(_ v1: T1, _ v2: T2, _ v3: T3, _ v4: T4, _ v5: T5, _ v6: T6, _ v7: T7) where T == (T1, T2, T3, T4, T5, T6, T7) {
    value = (v1, v2, v3, v4, v5, v6, v7)
    children = [AnyView(v1), AnyView(v2), AnyView(v3), AnyView(v4), AnyView(v5), AnyView(v6), AnyView(v7)]
  }

  init<T1: View, T2: View, T3: View, T4: View, T5: View, T6: View, T7: View, T8: View>(_ v1: T1, _ v2: T2, _ v3: T3, _ v4: T4, _ v5: T5, _ v6: T6, _ v7: T7, _ v8: T8) where T == (T1, T2, T3, T4, T5, T6, T7, T8) {
    value = (v1, v2, v3, v4, v5, v6, v7, v8)
    children = [AnyView(v1), AnyView(v2), AnyView(v3), AnyView(v4), AnyView(v5), AnyView(v6), AnyView(v7), AnyView(v8)]
  }

  init<T1: View, T2: View, T3: View, T4: View, T5: View, T6: View, T7: View, T8: View, T9: View>(_ v1: T1, _ v2: T2, _ v3: T3, _ v4: T4, _ v5: T5, _ v6: T6, _ v7: T7, _ v8: T8, _ v9: T9) where T == (T1, T2, T3, T4, T5, T6, T7, T8, T9) {
    value = (v1, v2, v3, v4, v5, v6, v7, v8, v9)
    children = [AnyView(v1), AnyView(v2), AnyView(v3), AnyView(v4), AnyView(v5), AnyView(v6), AnyView(v7), AnyView(v8), AnyView(v9)]
  }

  init<T1: View, T2: View, T3: View, T4: View, T5: View, T6: View, T7: View, T8: View, T9: View, T10: View>(_ v1: T1, _ v2: T2, _ v3: T3, _ v4: T4, _ v5: T5, _ v6: T6, _ v7: T7, _ v8: T8, _ v9: T9, _ v10: T10) where T == (T1, T2, T3, T4, T5, T6, T7, T8, T9, T10) {
    value = (v1, v2, v3, v4, v5, v6, v7, v8, v9, v10)
    children = [AnyView(v1), AnyView(v2), AnyView(v3), AnyView(v4), AnyView(v5), AnyView(v6), AnyView(v7), AnyView(v8), AnyView(v9), AnyView(v10)]
  }
}

extension TupleView: GroupView {}

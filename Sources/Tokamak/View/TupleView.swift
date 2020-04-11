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
}

extension TupleView: GroupView {}

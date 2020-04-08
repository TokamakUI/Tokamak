//
//  Created by Max Desiatov on 08/04/2020.
//

public struct TupleView<T>: View {
  public let value: T

  public init(_ value: T) { self.value = value }
}

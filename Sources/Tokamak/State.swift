//
//  Created by Max Desiatov on 08/04/2020.
//

@propertyWrapper public struct State<Value> {
  private let initialValue: Value

  public init(wrappedValue value: Value) {
    initialValue = value
  }

  public var wrappedValue: Value {
    get { binding?.wrappedValue ?? initialValue }
    nonmutating set { binding?.wrappedValue = newValue }
  }

  private var binding: Binding<Value>?

  public var projectedValue: Binding<Value> {
    binding!
  }
}

extension State where Value: ExpressibleByNilLiteral {
  @inlinable public init() { self.init(wrappedValue: nil) }
}

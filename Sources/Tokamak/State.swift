//
//  Created by Max Desiatov on 08/04/2020.
//

protocol ValueStorage {
  var valueType: Any.Type { get }
  var binding: Any? { get set }
}

@propertyWrapper public struct State<Value> {
  private let initialValue: Value

  let valueType: Any.Type

  public init(wrappedValue value: Value) {
    initialValue = value
    valueType = Value.self
  }

  public var wrappedValue: Value {
    get { (binding as? Binding<Value>)?.wrappedValue ?? initialValue }
    nonmutating set { (binding as? Binding<Value>)?.wrappedValue = newValue }
  }

  var binding: Any?

  public var projectedValue: Binding<Value> {
    // swiftlint:disable:next force_cast
    binding as! Binding<Value>
  }
}

extension State: ValueStorage {}

extension State where Value: ExpressibleByNilLiteral {
  @inlinable public init() { self.init(wrappedValue: nil) }
}

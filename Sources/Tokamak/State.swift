//
//  Created by Max Desiatov on 08/04/2020.
//

protocol ValueStorage {
  var getter: (() -> Any)? { get set }
  var setter: ((Any) -> ())? { get set }
  var anyInitialValue: Any { get }
}

@propertyWrapper public struct State<Value> {
  private let initialValue: Value

  var anyInitialValue: Any { initialValue }

  var getter: (() -> Any)?
  var setter: ((Any) -> ())?

  public init(wrappedValue value: Value) {
    initialValue = value
  }

  public var wrappedValue: Value {
    get { getter?() as? Value ?? initialValue }
    nonmutating set { setter?(newValue) }
  }

  public var projectedValue: Binding<Value> {
    guard let getter = getter, let setter = setter else {
      fatalError("\(#function) not available outside of `body`")
    }
    // swiftlint:disable:next force_cast
    return .init(get: { getter() as! Value }, set: { setter($0) })
  }
}

extension State: ValueStorage {}

extension State where Value: ExpressibleByNilLiteral {
  @inlinable public init() { self.init(wrappedValue: nil) }
}

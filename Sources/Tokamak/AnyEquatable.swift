//
//  AnyEquatable.swift
//  Tokamak
//
//  Created by Max Desiatov on 06/11/2018.
//

/** Type-erased version of `Equatable` that allows you to compare values of
 different types. Main use of `AnyEquatable` in Tokamak is to wrap `Props` and
 `Children` before storing those in `AnyNode`.

 Example:

 ```swift
 AnyEquatable(42) == AnyEquatable(42) // is `true`
 AnyEquatable(42) == AnyEquatable("forty two") // is `false`
 ```
 */
public struct AnyEquatable: Equatable {
  public let value: Any
  private let equals: (Any) -> Bool

  public init<E: Equatable>(_ value: E) {
    self.value = value
    equals = { ($0 as? E) == value }
  }

  public static func ==(lhs: AnyEquatable, rhs: AnyEquatable) -> Bool {
    return lhs.equals(rhs.value) || rhs.equals(lhs.value)
  }
}

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

public struct Transaction {
  /// The overridden transaction for a state change in a `withTransaction` block.
  /// Is always set back to `nil` when the block exits.
  static var _active: Self?

  public var animation: Animation?

  /** `true` in the first part of the transition update, this avoids situations when `animation(_:)`
   could add more animations to this transaction.
   */
  public var disablesAnimations: Bool

  public init(animation: Animation?) {
    self.animation = animation
    disablesAnimations = false
  }
}

public func withTransaction<Result>(
  _ transaction: Transaction,
  _ body: () throws -> Result
) rethrows -> Result {
  Transaction._active = transaction
  defer { Transaction._active = nil }
  return try body()
}

public func withAnimation<Result>(
  _ animation: Animation? = .default,
  _ body: () throws -> Result
) rethrows -> Result {
  try withTransaction(.init(animation: animation), body)
}

protocol _TransactionModifierProtocol {
  func modifyTransaction(_ transaction: inout Transaction)
}

@frozen
public struct _TransactionModifier: ViewModifier {
  public var transform: (inout Transaction) -> ()

  @inlinable
  public init(transform: @escaping (inout Transaction) -> ()) {
    self.transform = transform
  }

  public func body(content: Content) -> some View {
    content
  }
}

extension _TransactionModifier: _TransactionModifierProtocol {
  func modifyTransaction(_ transaction: inout Transaction) {
    transform(&transaction)
  }
}

extension ModifiedContent: _TransactionModifierProtocol
  where Modifier: _TransactionModifierProtocol
{
  func modifyTransaction(_ transaction: inout Transaction) {
    modifier.modifyTransaction(&transaction)
  }
}

@frozen
public struct _PushPopTransactionModifier<V>: ViewModifier where V: ViewModifier {
  public var content: V
  public var base: _TransactionModifier

  @inlinable
  public init(
    content: V,
    transform: @escaping (inout Transaction) -> ()
  ) {
    self.content = content
    base = .init(transform: transform)
  }

  public func body(content: Content) -> some View {
    content
      .modifier(self.content)
      .modifier(base)
  }
}

public extension View {
  @inlinable
  func transaction(_ transform: @escaping (inout Transaction) -> ()) -> some View {
    modifier(_TransactionModifier(transform: transform))
  }
}

public extension ViewModifier {
  @inlinable
  func transaction(
    _ transform: @escaping (inout Transaction) -> ()
  ) -> some ViewModifier {
    _PushPopTransactionModifier(content: self, transform: transform)
  }

  @inlinable
  func animation(
    _ animation: Animation?
  ) -> some ViewModifier {
    transaction { t in
      if !t.disablesAnimations {
        t.animation = animation
      }
    }
  }
}

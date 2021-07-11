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
  /// The overriden transaction for a state change in a `withTransaction` block.
  /// Is always set back to `nil` when the block exits.
  static var _active: Self?

  public var animation: Animation?

  /** `true` in the first part of the transition update, this avoids situations when `animation(_:)`
   could add more animations to this transaction.
   */
  public var disablesAnimations: Bool

  public init(animation: Animation?) {
    self.animation = animation
    disablesAnimations = true
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

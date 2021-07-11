// Copyright 2019-2020 Tokamak contributors
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
//  Created by Max Desiatov on 09/02/2019.
//

/** Note that `set` functions are not `mutating`, they never update the
 view's state in-place synchronously, but only schedule an update with
 the renderer at a later time.
 */
@propertyWrapper
@dynamicMemberLookup
public struct Binding<Value>: DynamicProperty {
  public var wrappedValue: Value {
    get { get() }
    nonmutating set { set(newValue, transaction) }
  }

  public var transaction: Transaction

  private let get: () -> Value
  private let set: (Value, Transaction) -> ()

  public var projectedValue: Binding<Value> { self }

  public init(get: @escaping () -> Value, set: @escaping (Value) -> ()) {
    self.get = get
    self.set = { v, _ in set(v) }
    transaction = .init(animation: nil)
  }

  public init(get: @escaping () -> Value, set: @escaping (Value, Transaction) -> ()) {
    self.transaction = .init(animation: nil)
    self.get = get
    self.set = {
      set($0, $1)
    }
  }

  public subscript<Subject>(
    dynamicMember keyPath: WritableKeyPath<Value, Subject>
  ) -> Binding<Subject> {
    .init(
      get: {
        self.wrappedValue[keyPath: keyPath]
      }, set: {
        self.wrappedValue[keyPath: keyPath] = $0
      }
    )
  }

  public static func constant(_ value: Value) -> Self {
    .init(get: { value }, set: { _ in })
  }
}

public extension Binding {
  func transaction(_ transaction: Transaction) -> Binding<Value> {
    var binding = self
    binding.transaction = transaction
    return binding
  }

  func animation(_ animation: Animation? = .default) -> Binding<Value> {
    transaction(.init(animation: animation))
  }
}

extension Binding: Identifiable where Value: Identifiable {
  public var id: Value.ID { wrappedValue.id }
}

extension Binding: Sequence where Value: MutableCollection {
  public typealias Element = Binding<Value.Element>
  public typealias Iterator = IndexingIterator<Binding<Value>>
  public typealias SubSequence = Slice<Binding<Value>>
}

extension Binding: Collection where Value: MutableCollection {
  public typealias Index = Value.Index
  public typealias Indices = Value.Indices
  public var startIndex: Binding<Value>.Index { wrappedValue.startIndex }
  public var endIndex: Binding<Value>.Index { wrappedValue.endIndex }
  public var indices: Value.Indices { wrappedValue.indices }

  public func index(after i: Binding<Value>.Index) -> Binding<Value>.Index {
    wrappedValue.index(after: i)
  }

  public func formIndex(after i: inout Binding<Value>.Index) {
    wrappedValue.formIndex(after: &i)
  }

  public subscript(position: Binding<Value>.Index) -> Binding<Value>.Element {
    Binding<Value.Element> {
      wrappedValue[position]
    } set: {
      wrappedValue[position] = $0
    }
  }
}

extension Binding: BidirectionalCollection where Value: BidirectionalCollection,
  Value: MutableCollection
{
  public func index(before i: Binding<Value>.Index) -> Binding<Value>.Index {
    wrappedValue.index(before: i)
  }

  public func formIndex(before i: inout Binding<Value>.Index) {
    wrappedValue.formIndex(before: &i)
  }
}

extension Binding: RandomAccessCollection where Value: MutableCollection,
  Value: RandomAccessCollection {}

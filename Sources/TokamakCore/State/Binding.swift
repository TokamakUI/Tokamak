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

typealias Updater<T> = (inout T) -> ()

/** Note that `set` functions are not `mutating`, they never update the
 view's state in-place synchronously, but only schedule an update with
 the renderer at a later time.
 */
@propertyWrapper public struct Binding<Value>: DynamicProperty {
  public var wrappedValue: Value {
    get { get() }
    nonmutating set { set(newValue) }
  }

  private let get: () -> Value
  private let set: (Value) -> ()

  public var projectedValue: Binding<Value> { self }

  public init(get: @escaping () -> Value, set: @escaping (Value) -> ()) {
    self.get = get
    self.set = set
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

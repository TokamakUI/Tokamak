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

import CombineShim

@propertyWrapper
public struct StateObject<ObjectType: ObservableObject>: DynamicProperty {
  enum Storage {
    case initially(() -> ObjectType)
    case object(ObservedObject<ObjectType>)
  }

  var storage: Storage

  public var wrappedValue: ObjectType { projectedValue.root }

  public init(wrappedValue thunk: @autoclosure @escaping () -> ObjectType) {
    storage = .initially(thunk)
  }

  public var projectedValue: ObservedObject<ObjectType>.Wrapper {
    switch storage {
    case let .object(observed): return observed.projectedValue
    default: fatalError()
    }
  }

  var objectWillChange: AnyPublisher<(), Never> {
    wrappedValue.objectWillChange.map { _ in }.eraseToAnyPublisher()
  }
}

extension StateObject: ObservedProperty {}

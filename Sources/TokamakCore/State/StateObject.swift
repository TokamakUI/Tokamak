// Copyright 2020-2021 Tokamak contributors
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

import OpenCombineShim

@propertyWrapper
public struct StateObject<ObjectType: ObservableObject>: DynamicProperty {
  public var wrappedValue: ObjectType { (getter?() as? ObservedObject.Wrapper)?.root ?? initial() }

  let initial: () -> ObjectType
  var getter: (() -> Any)?

  public init(wrappedValue initial: @autoclosure @escaping () -> ObjectType) {
    self.initial = initial
  }

  public var projectedValue: ObservedObject<ObjectType>.Wrapper {
    getter?() as? ObservedObject.Wrapper ?? ObservedObject.Wrapper(root: initial())
  }
}

extension StateObject: ObservedProperty {
  var objectWillChange: AnyPublisher<(), Never> {
    wrappedValue.objectWillChange.map { _ in }.eraseToAnyPublisher()
  }
}

extension StateObject: ValueStorage {
  var anyInitialValue: Any {
    ObservedObject.Wrapper(root: initial())
  }
}

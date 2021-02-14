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

public typealias ObservableObject = OpenCombineShim.ObservableObject
public typealias Published = OpenCombineShim.Published

protocol ObservedProperty: DynamicProperty {
  var objectWillChange: AnyPublisher<(), Never> { get }
}

@propertyWrapper
public struct ObservedObject<ObjectType>: DynamicProperty where ObjectType: ObservableObject {
  @dynamicMemberLookup
  public struct Wrapper {
    let root: ObjectType
    public subscript<Subject>(
      dynamicMember keyPath: ReferenceWritableKeyPath<ObjectType, Subject>
    ) -> Binding<Subject> {
      .init(
        get: {
          self.root[keyPath: keyPath]
        },
        set: {
          self.root[keyPath: keyPath] = $0
        }
      )
    }
  }

  public var wrappedValue: ObjectType { projectedValue.root }

  public init(wrappedValue: ObjectType) {
    projectedValue = Wrapper(root: wrappedValue)
  }

  public let projectedValue: Wrapper
}

extension ObservedObject: ObservedProperty {
  var objectWillChange: AnyPublisher<(), Never> {
    wrappedValue.objectWillChange.map { _ in }.eraseToAnyPublisher()
  }
}

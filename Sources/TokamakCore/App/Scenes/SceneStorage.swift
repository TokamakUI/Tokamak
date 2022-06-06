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
//
//  Created by Carson Katri on 7/17/20.
//

import OpenCombineShim

/// The renderer must specify a default `_StorageProvider` before any `SceneStorage`
/// values are accessed.
public enum _DefaultSceneStorageProvider {
  public static var `default`: _StorageProvider!
}

@propertyWrapper
public struct SceneStorage<Value>: DynamicProperty {
  let key: String
  let defaultValue: Value
  let store: (_StorageProvider, String, Value) -> ()
  let read: (_StorageProvider, String) -> Value?

  var objectWillChange: AnyPublisher<(), Never> {
    _DefaultSceneStorageProvider.default.publisher.eraseToAnyPublisher()
  }

  public var wrappedValue: Value {
    get {
      read(_DefaultSceneStorageProvider.default, key) ?? defaultValue
    }
    nonmutating set {
      store(_DefaultSceneStorageProvider.default, key, newValue)
    }
  }

  public var projectedValue: Binding<Value> {
    .init {
      wrappedValue
    } set: {
      wrappedValue = $0
    }
  }
}

extension SceneStorage: ObservedProperty {}

public extension SceneStorage {
  init(wrappedValue: Value, _ key: String) where Value == Bool {
    defaultValue = wrappedValue
    self.key = key
    store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  init(wrappedValue: Value, _ key: String) where Value == Int {
    defaultValue = wrappedValue
    self.key = key
    store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  init(wrappedValue: Value, _ key: String) where Value == Double {
    defaultValue = wrappedValue
    self.key = key
    store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  init(wrappedValue: Value, _ key: String) where Value == String {
    defaultValue = wrappedValue
    self.key = key
    store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  init(wrappedValue: Value, _ key: String) where Value: RawRepresentable,
    Value.RawValue == Int
  {
    defaultValue = wrappedValue
    self.key = key
    store = { $0.store(key: $1, value: $2.rawValue) }
    read = {
      guard let rawValue = $0.read(key: $1) as Int? else {
        return nil
      }
      return Value(rawValue: rawValue)
    }
  }

  init(wrappedValue: Value, _ key: String)
    where Value: RawRepresentable, Value.RawValue == String
  {
    defaultValue = wrappedValue
    self.key = key
    store = { $0.store(key: $1, value: $2.rawValue) }
    read = {
      guard let rawValue = $0.read(key: $1) as String? else {
        return nil
      }
      return Value(rawValue: rawValue)
    }
  }
}

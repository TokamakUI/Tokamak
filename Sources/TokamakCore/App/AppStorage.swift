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
//  Created by Carson Katri on 7/16/20.
//

import OpenCombineShim

@propertyWrapper
public struct AppStorage<Value>: DynamicProperty {
  let provider: _StorageProvider?

  @Environment(\._defaultAppStorage)
  var defaultProvider: _StorageProvider?

  var unwrappedProvider: _StorageProvider {
    provider ?? defaultProvider!
  }

  let key: String
  let defaultValue: Value
  let store: (_StorageProvider, String, Value) -> ()
  let read: (_StorageProvider, String) -> Value?

  var objectWillChange: AnyPublisher<(), Never> {
    unwrappedProvider.publisher.eraseToAnyPublisher()
  }

  public var wrappedValue: Value {
    get {
      read(unwrappedProvider, key) ?? defaultValue
    }
    nonmutating set {
      store(unwrappedProvider, key, newValue)
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

extension AppStorage: ObservedProperty {}

public extension AppStorage {
  init(wrappedValue: Value, _ key: String, store: _StorageProvider? = nil)
    where Value == Bool
  {
    defaultValue = wrappedValue
    self.key = key
    provider = store
    self.store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  init(wrappedValue: Value, _ key: String, store: _StorageProvider? = nil)
    where Value == Int
  {
    defaultValue = wrappedValue
    self.key = key
    provider = store
    self.store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  init(wrappedValue: Value, _ key: String, store: _StorageProvider? = nil)
    where Value == Double
  {
    defaultValue = wrappedValue
    self.key = key
    provider = store
    self.store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  init(wrappedValue: Value, _ key: String, store: _StorageProvider? = nil)
    where Value == String
  {
    defaultValue = wrappedValue
    self.key = key
    provider = store
    self.store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  init(wrappedValue: Value, _ key: String, store: _StorageProvider? = nil)
    where Value: RawRepresentable, Value.RawValue == Int
  {
    defaultValue = wrappedValue
    self.key = key
    provider = store
    self.store = { $0.store(key: $1, value: $2.rawValue) }
    read = {
      guard let rawValue = $0.read(key: $1) as Int? else {
        return nil
      }
      return Value(rawValue: rawValue)
    }
  }

  init(wrappedValue: Value, _ key: String, store: _StorageProvider? = nil)
    where Value: RawRepresentable, Value.RawValue == String
  {
    defaultValue = wrappedValue
    self.key = key
    provider = store
    self.store = { $0.store(key: $1, value: $2.rawValue) }
    read = {
      guard let rawValue = $0.read(key: $1) as String? else {
        return nil
      }
      return Value(rawValue: rawValue)
    }
  }
}

public extension AppStorage where Value: ExpressibleByNilLiteral {
  init(wrappedValue: Value, _ key: String, store: _StorageProvider? = nil)
    where Value == Bool?
  {
    defaultValue = wrappedValue
    self.key = key
    provider = store
    self.store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  init(wrappedValue: Value, _ key: String, store: _StorageProvider? = nil)
    where Value == Int?
  {
    defaultValue = wrappedValue
    self.key = key
    provider = store
    self.store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  init(wrappedValue: Value, _ key: String, store: _StorageProvider? = nil)
    where Value == Double?
  {
    defaultValue = wrappedValue
    self.key = key
    provider = store
    self.store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  init(wrappedValue: Value, _ key: String, store: _StorageProvider? = nil)
    where Value == String?
  {
    defaultValue = wrappedValue
    self.key = key
    provider = store
    self.store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }
}

/// The renderer is responsible for making sure a default is set at the root of the App.
struct DefaultAppStorageEnvironmentKey: EnvironmentKey {
  static let defaultValue: _StorageProvider? = nil
}

public extension EnvironmentValues {
  @_spi(TokamakCore)
  var _defaultAppStorage: _StorageProvider? {
    get {
      self[DefaultAppStorageEnvironmentKey.self]
    }
    set {
      self[DefaultAppStorageEnvironmentKey.self] = newValue
    }
  }
}

public extension View {
  func defaultAppStorage(_ store: _StorageProvider) -> some View {
    environment(\._defaultAppStorage, store)
  }
}

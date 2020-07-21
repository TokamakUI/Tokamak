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
//
//  Created by Carson Katri on 7/16/20.
//

import OpenCombine

public protocol _AppStorageProvider {
  func store(key: String, value: Bool?)
  func store(key: String, value: Int?)
  func store(key: String, value: Double?)
  func store(key: String, value: String?)

  func read(key: String) -> Bool?
  func read(key: String) -> Int?
  func read(key: String) -> Double?
  func read(key: String) -> String?

  static var standard: _AppStorageProvider { get }
  var publisher: ObservableObjectPublisher { get }
}

@propertyWrapper public struct AppStorage<Value>: ObservedProperty {
  let provider: _AppStorageProvider?
  @Environment(\._defaultAppStorage) var defaultProvider: _AppStorageProvider?
  var unwrappedProvider: _AppStorageProvider {
    provider ?? defaultProvider!
  }

  let key: String
  let defaultValue: Value
  let store: (_AppStorageProvider, String, Value) -> ()
  let read: (_AppStorageProvider, String) -> Value?

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

extension AppStorage: DynamicProperty {}

extension AppStorage {
  public init(wrappedValue: Value,
              _ key: String,
              store: _AppStorageProvider? = nil) where Value == Bool {
    defaultValue = wrappedValue
    self.key = key
    provider = store
    self.store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  public init(wrappedValue: Value,
              _ key: String,
              store: _AppStorageProvider? = nil) where Value == Int {
    defaultValue = wrappedValue
    self.key = key
    provider = store
    self.store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  public init(wrappedValue: Value,
              _ key: String,
              store: _AppStorageProvider? = nil) where Value == Double {
    defaultValue = wrappedValue
    self.key = key
    provider = store
    self.store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  public init(wrappedValue: Value,
              _ key: String,
              store: _AppStorageProvider? = nil) where Value == String {
    defaultValue = wrappedValue
    self.key = key
    provider = store
    self.store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  public init(wrappedValue: Value,
              _ key: String,
              store: _AppStorageProvider? = nil)
    where Value: RawRepresentable, Value.RawValue == Int {
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

  public init(wrappedValue: Value,
              _ key: String,
              store: _AppStorageProvider? = nil)
    where Value: RawRepresentable, Value.RawValue == String {
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

extension AppStorage where Value: ExpressibleByNilLiteral {
  public init(wrappedValue: Value,
              _ key: String,
              store: _AppStorageProvider? = nil) where Value == Bool? {
    defaultValue = wrappedValue
    self.key = key
    provider = store
    self.store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  public init(wrappedValue: Value,
              _ key: String,
              store: _AppStorageProvider? = nil) where Value == Int? {
    defaultValue = wrappedValue
    self.key = key
    provider = store
    self.store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  public init(wrappedValue: Value,
              _ key: String,
              store: _AppStorageProvider? = nil) where Value == Double? {
    defaultValue = wrappedValue
    self.key = key
    provider = store
    self.store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }

  public init(wrappedValue: Value,
              _ key: String,
              store: _AppStorageProvider? = nil) where Value == String? {
    defaultValue = wrappedValue
    self.key = key
    provider = store
    self.store = { $0.store(key: $1, value: $2) }
    read = { $0.read(key: $1) }
  }
}

/// The renderer is responsible for making sure a default is set at the root of the App.
struct DefaultAppStorageEnvironmentKey: EnvironmentKey {
  static let defaultValue: _AppStorageProvider? = nil
}

extension EnvironmentValues {
  public var _defaultAppStorage: _AppStorageProvider? {
    get {
      self[DefaultAppStorageEnvironmentKey.self]
    }
    set {
      self[DefaultAppStorageEnvironmentKey.self] = newValue
    }
  }
}

extension View {
  public func defaultAppStorage(_ store: _AppStorageProvider) -> some View {
    environment(\._defaultAppStorage, store)
  }
}

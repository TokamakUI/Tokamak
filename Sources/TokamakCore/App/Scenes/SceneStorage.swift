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
//  Created by Carson Katri on 7/17/20.
//

import OpenCombine

public protocol _SceneStorageProvider {
  func store(key: String, value: String)
  func read(key: String) -> String?
  static var standard: _SceneStorageProvider { get }
  var publisher: ObservableObjectPublisher { get }
}

/// The renderer must specify a default `_SceneStorageProvider` before any `SceneStorage`
/// values are accessed.
public enum _DefaultSceneStorageProvider {
  public static var `default`: _SceneStorageProvider!
}

@propertyWrapper public struct SceneStorage<Value>: ObservedProperty {
  let key: String
  let defaultValue: Value
  let wrapValue: (Value) -> String
  let unwrapValue: (String) -> Value?

  var objectWillChange: AnyPublisher<(), Never> {
    _DefaultSceneStorageProvider.default.publisher.eraseToAnyPublisher()
  }

  public var wrappedValue: Value {
    get {
      if let stringValue = _DefaultSceneStorageProvider.default.read(key: key) {
        return unwrapValue(stringValue) ?? defaultValue
      }
      return defaultValue
    }
    nonmutating set {
      _DefaultSceneStorageProvider.default.store(key: key, value: wrapValue(newValue))
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

extension SceneStorage {
  public init(wrappedValue: Value,
              _ key: String) where Value == Bool {
    defaultValue = wrappedValue
    self.key = key
    wrapValue = { String($0) }
    unwrapValue = { Bool($0) }
  }

  public init(wrappedValue: Value,
              _ key: String) where Value == Int {
    defaultValue = wrappedValue
    self.key = key
    wrapValue = { String($0) }
    unwrapValue = { Int($0) }
  }

  public init(wrappedValue: Value,
              _ key: String) where Value == Double {
    defaultValue = wrappedValue
    self.key = key
    wrapValue = { String($0) }
    unwrapValue = { Double($0) }
  }

  public init(wrappedValue: Value,
              _ key: String) where Value == String {
    defaultValue = wrappedValue
    self.key = key
    wrapValue = { $0 }
    unwrapValue = { $0 }
  }

  public init(wrappedValue: Value,
              _ key: String)
    where Value: RawRepresentable, Value.RawValue == Int {
    defaultValue = wrappedValue
    self.key = key
    wrapValue = { String($0.rawValue) }
    unwrapValue = {
      guard let rawValue = Int($0) else {
        return nil
      }
      return Value(rawValue: rawValue)
    }
  }

  public init(wrappedValue: Value,
              _ key: String)
    where Value: RawRepresentable, Value.RawValue == String {
    defaultValue = wrappedValue
    self.key = key
    wrapValue = { $0.rawValue }
    unwrapValue = { Value(rawValue: $0) }
  }
}

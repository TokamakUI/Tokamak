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

public enum _AppStorageValue {
  case bool(Bool)
  case int(Int)
  case double(Double)
  case string(String)
}

public protocol _AppStorageProvider {
  func store(key: String, value: _AppStorageValue)
  func read(key: String) -> _AppStorageValue?
  static var standard: _AppStorageProvider { get }
}

@propertyWrapper public struct AppStorage<Value>: ObservedProperty {
  let provider: _AppStorageProvider
  let key: String
  let defaultValue: Value
  let wrapValue: (Value) -> _AppStorageValue
  let unwrapValue: (_AppStorageValue?) -> Value?

  let publisher = ObservableObjectPublisher()
  var objectWillChange: AnyPublisher<(), Never> {
    publisher.eraseToAnyPublisher()
  }

  public var wrappedValue: Value {
    get {
      unwrapValue(provider.read(key: key)) ?? defaultValue
    }
    nonmutating set {
      publisher.send()
      provider.store(key: key, value: wrapValue(newValue))
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

extension AppStorage {
  public init<Store: _AppStorageProvider>(wrappedValue: Value, _ key: String, store: Store? = nil) where Value == Bool {
    defaultValue = wrappedValue
    self.key = key
    provider = store ?? Store.standard
    wrapValue = { .bool($0) }
    unwrapValue = {
      if case let .bool(bool) = $0 {
        return bool
      } else {
        return nil
      }
    }
  }

  public init<Store: _AppStorageProvider>(wrappedValue: Value, _ key: String, store: Store? = nil) where Value == Int {
    defaultValue = wrappedValue
    self.key = key
    provider = store ?? Store.standard
    wrapValue = { .int($0) }
    unwrapValue = {
      if case let .int(int) = $0 {
        return int
      } else {
        return nil
      }
    }
  }

//  public init(wrappedValue: Value, _ key: String, store: _AppStorageProvider? = nil) where Value == Double
//  public init(wrappedValue: Value, _ key: String, store: _AppStorageProvider? = nil) where Value == String
//  public init(wrappedValue: Value, _ key: String, store: _AppStorageProvider? = nil) where Value : RawRepresentable, Value.RawValue == Int
//  public init(wrappedValue: Value, _ key: String, store: _AppStorageProvider? = nil) where Value : RawRepresentable, Value.RawValue == String
}

// extension AppStorage where Value : Swift.ExpressibleByNilLiteral {
//  public init(_ key: Swift.String, store: Foundation.UserDefaults? = nil) where Value == Swift.Bool?
//  public init(_ key: Swift.String, store: Foundation.UserDefaults? = nil) where Value == Swift.Int?
//  public init(_ key: Swift.String, store: Foundation.UserDefaults? = nil) where Value == Swift.Double?
//  public init(_ key: Swift.String, store: Foundation.UserDefaults? = nil) where Value == Swift.String?
//  public init(_ key: Swift.String, store: Foundation.UserDefaults? = nil) where Value == Foundation.URL?
//  public init(_ key: Swift.String, store: Foundation.UserDefaults? = nil) where Value == Foundation.Data?
// }
// @available(iOS 14.0, OSX 10.16, tvOS 14.0, watchOS 7.0, *)
// extension View {
//  public func defaultAppStorage(_ store: Foundation.UserDefaults) -> some SwiftUI.View
//
// }
// @available(iOS 14.0, OSX 10.16, tvOS 14.0, watchOS 7.0, *)
// extension Scene {
//  public func defaultAppStorage(_ store: Foundation.UserDefaults) -> some SwiftUI.Scene
//
// }
// @available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
// extension EnvironmentValues {
//  @usableFromInline
//  internal var defaultAppStorageDefaults: Foundation.UserDefaults {
//    get
//    set
//  }
// }

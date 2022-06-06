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

/// A protocol that allows the conforming type to access values from the `EnvironmentValues`.
/// (e.g. `Environment` and `EnvironmentObject`)
///
/// `EnvironmentValues` are injected in 2 places:
/// 1. `View.makeMountedView`
/// 2. `MountedHostView.update` when reconciling
///
protocol EnvironmentReader {
  mutating func setContent(from values: EnvironmentValues)
}

@propertyWrapper
public struct Environment<Value>: DynamicProperty {
  enum Content {
    case keyPath(KeyPath<EnvironmentValues, Value>)
    case value(Value)
  }

  private var content: Content
  private let keyPath: KeyPath<EnvironmentValues, Value>
  public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
    content = .keyPath(keyPath)
    self.keyPath = keyPath
  }

  mutating func setContent(from values: EnvironmentValues) {
    content = .value(values[keyPath: keyPath])
  }

  public var wrappedValue: Value {
    switch content {
    case let .value(value):
      return value
    case let .keyPath(keyPath):
      // not bound to a view, return the default value.
      return EnvironmentValues()[keyPath: keyPath]
    }
  }
}

extension Environment: EnvironmentReader {}

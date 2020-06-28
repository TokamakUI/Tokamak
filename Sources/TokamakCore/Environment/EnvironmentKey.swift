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

public protocol EnvironmentKey {
  associatedtype Value
  static var defaultValue: Self.Value { get }
}

public struct _EnvironmentKeyWritingModifier<Value>: ViewModifier {
  public typealias Body = Never

  public let keyPath: WritableKeyPath<EnvironmentValues, Value>
  public let value: Value

  public init(keyPath: WritableKeyPath<EnvironmentValues, Value>, value: Value) {
    self.keyPath = keyPath
    self.value = value
  }
}

extension View {
  public func environment<V>(_ keyPath: WritableKeyPath<EnvironmentValues, V>, _ value: V) -> some View {
    modifier(_EnvironmentKeyWritingModifier(keyPath: keyPath, value: value))
  }
}

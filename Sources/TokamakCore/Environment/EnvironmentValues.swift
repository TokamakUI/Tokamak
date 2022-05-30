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

public struct EnvironmentValues: CustomStringConvertible {
  public var description: String {
    "EnvironmentValues: \(values.count)"
  }

  private var values: [ObjectIdentifier: Any] = [:]

  public init() {}

  public subscript<K>(key: K.Type) -> K.Value where K: EnvironmentKey {
    get {
      if let val = values[ObjectIdentifier(key)] as? K.Value {
        return val
      }
      return K.defaultValue
    }
    set {
      values[ObjectIdentifier(key)] = newValue
    }
  }

  subscript<B>(bindable: ObjectIdentifier) -> B? where B: ObservableObject {
    get {
      values[bindable] as? B
    }
    set {
      values[bindable] = newValue
    }
  }

  @_spi(TokamakCore)
  public mutating func merge(_ other: Self?) {
    if let other = other {
      values.merge(other.values) { _, new in
        new
      }
    }
  }

  @_spi(TokamakCore)
  public func merging(_ other: Self?) -> Self {
    var merged = self
    merged.merge(other)
    return merged
  }
}

struct IsEnabledKey: EnvironmentKey {
  static let defaultValue = true
}

public extension EnvironmentValues {
  var isEnabled: Bool {
    get {
      self[IsEnabledKey.self]
    }
    set {
      self[IsEnabledKey.self] = newValue
    }
  }
}

struct _EnvironmentValuesWritingModifier: ViewModifier, _EnvironmentModifier {
  let environmentValues: EnvironmentValues

  func body(content: Content) -> some View {
    content
  }

  func modifyEnvironment(_ values: inout EnvironmentValues) {
    values = environmentValues
  }
}

public extension View {
  func environmentValues(_ values: EnvironmentValues) -> some View {
    modifier(_EnvironmentValuesWritingModifier(environmentValues: values))
  }
}

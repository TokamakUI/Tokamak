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
//  Created by Carson Katri on 11/26/20.
//

public protocol PreferenceKey {
  associatedtype Value
  static var defaultValue: Value { get }
  static func reduce(value: inout Value, nextValue: () -> Value)
}

extension PreferenceKey where Self.Value: ExpressibleByNilLiteral {
  public static var defaultValue: Value { nil }
}

protocol _AnyPreferenceValue {
  var valueListCount: Int { get }
}

public struct _PreferenceValue<Key> where Key: PreferenceKey {
  /// Every value the `Key` has had.
  var valueList: [Key.Value]
  /// The latest value.
  public var value: Key.Value {
    reduce(valueList)
  }

  func reduce(_ values: [Key.Value]) -> Key.Value {
    values.reduce(into: Key.defaultValue) { prev, next in
      Key.reduce(value: &prev) { next }
    }
  }
}

extension _PreferenceValue: _AnyPreferenceValue {
  var valueListCount: Int { valueList.count }
}

public struct _PreferenceStore {
  /// The backing values of the `_PreferenceStore`.
  private var values: [String: Any]

  public init(values: [String: Any] = [:]) {
    self.values = values
  }

  public func value<Key>(forKey key: Key.Type = Key.self) -> _PreferenceValue<Key>
    where Key: PreferenceKey
  {
    values[String(describing: key)] as? _PreferenceValue<Key>
      ?? _PreferenceValue(valueList: [Key.defaultValue])
  }

  public mutating func insert<Key>(_ value: Key.Value, forKey key: Key.Type = Key.self)
    where Key: PreferenceKey
  {
    let previousValues = self.value(forKey: key).valueList
    values[String(describing: key)] = _PreferenceValue<Key>(valueList: previousValues + [value])
  }

  public mutating func merge(with other: Self) {
    self = merging(with: other)
  }

  public func merging(with other: Self) -> Self {
    var result = values
    for (key, value) in other.values {
      result[key] = value
    }
    return .init(values: result)
  }
}

public protocol _PreferenceModifier: ViewModifier
  where Body == Never
{
  func modifyPreferenceStore(_ preferenceStore: inout _PreferenceStore)
}

public protocol _PreferenceModifyingView {
  func modifyPreferenceStore(_ preferenceStore: inout _PreferenceStore) -> AnyView
}

extension _PreferenceModifyingView where Self: View {
  public var body: Never {
    neverBody(String(describing: Self.self))
  }
}

extension ModifiedContent: _PreferenceModifyingView
  where Content: View, Modifier: _PreferenceModifier
{
  public func modifyPreferenceStore(_ preferenceStore: inout _PreferenceStore) -> AnyView {
    modifier.modifyPreferenceStore(&preferenceStore)
    return AnyView(content)
  }
}

public struct PreferredColorSchemeKey: PreferenceKey {
  public typealias Value = ColorScheme?
  public static func reduce(value: inout Value, nextValue: () -> Value) {
    value = nextValue()
  }
}

extension View {
  public func preferredColorScheme(_ colorScheme: ColorScheme?) -> some View {
    preference(key: PreferredColorSchemeKey.self, value: colorScheme)
  }
}

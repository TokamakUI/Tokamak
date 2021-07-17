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

public extension PreferenceKey where Self.Value: ExpressibleByNilLiteral {
  static var defaultValue: Value { nil }
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

public extension _PreferenceValue {
  func _force<V>(
    _ transform: @escaping (Key.Value) -> V
  ) -> _PreferenceReadingView<Key, V> where V: View {
    _PreferenceReadingView(value: self, transform: transform)
  }
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
    values[String(reflecting: key)] as? _PreferenceValue<Key>
      ?? _PreferenceValue(valueList: [Key.defaultValue])
  }

  public mutating func insert<Key>(_ value: Key.Value, forKey key: Key.Type = Key.self)
    where Key: PreferenceKey
  {
    let previousValues = self.value(forKey: key).valueList
    values[String(reflecting: key)] = _PreferenceValue<Key>(valueList: previousValues + [value])
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

/// A protocol that allows a `View` to read values from the current `_PreferenceStore`.
/// The key difference between `_PreferenceReadingViewProtocol` and
/// `_PreferenceWritingViewProtocol` is that `_PreferenceReadingViewProtocol`
/// calls `preferenceStore` during the current render, and `_PreferenceWritingViewProtocol`
/// waits until the current render finishes.
public protocol _PreferenceReadingViewProtocol {
  func preferenceStore(_ preferenceStore: _PreferenceStore)
}

/// A protocol that allows a `View` to modify values from the current `_PreferenceStore`.
public protocol _PreferenceWritingViewProtocol {
  func modifyPreferenceStore(_ preferenceStore: inout _PreferenceStore) -> AnyView
}

/// A protocol that allows a `ViewModifier` to modify values from the current `_PreferenceStore`.
public protocol _PreferenceWritingModifierProtocol: ViewModifier
  where Body == AnyView
{
  func body(_ content: Self.Content, with preferenceStore: inout _PreferenceStore) -> AnyView
}

public extension _PreferenceWritingModifierProtocol {
  func body(content: Content) -> AnyView {
    content.view
  }
}

extension ModifiedContent: _PreferenceWritingViewProtocol
  where Content: View, Modifier: _PreferenceWritingModifierProtocol
{
  public func modifyPreferenceStore(_ preferenceStore: inout _PreferenceStore) -> AnyView {
    AnyView(
      modifier
        .body(.init(modifier: modifier, view: AnyView(content)), with: &preferenceStore)
    )
  }
}

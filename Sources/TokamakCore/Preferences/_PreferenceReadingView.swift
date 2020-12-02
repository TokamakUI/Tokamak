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

/// Accesses a `PreferenceKey.Value`.
public struct _PreferenceReadingView<Key, Content>: View, _PreferenceReadingViewProtocol
  where Key: PreferenceKey, Content: View
{
  public let value: _PreferenceValue<Key>
  public let transform: (Key.Value) -> Content

  public init(
    value: _PreferenceValue<Key>,
    transform: @escaping (Key.Value) -> Content
  ) {
    self.value = value
    self.transform = transform
  }

  public func preferenceStore(_ preferenceStore: _PreferenceStore) -> AnyView {
    AnyView(transform(
      preferenceStore.value(forKey: Key.self).value
    ))
  }
}

extension _PreferenceValue {
  public func _force<T>(
    _ transform: @escaping (Key.Value) -> T
  ) -> _PreferenceReadingView<Key, T>
    where T: View
  {
    _PreferenceReadingView(value: self, transform: transform)
  }
}

/// Delays the retrieval of a `PreferenceKey.Value` by passing the `_PreferenceValue` to a build
/// function.
public struct _DelayedPreferenceView<Key, Content>: View, _PreferenceReadingViewProtocol
  where Key: PreferenceKey, Content: View
{
  public let transform: (_PreferenceValue<Key>) -> Content
  public init(transform: @escaping (_PreferenceValue<Key>) -> Content) {
    self.transform = transform
  }

  public func preferenceStore(_ preferenceStore: _PreferenceStore) -> AnyView {
    AnyView(
      transform(preferenceStore.value(forKey: Key.self))
    )
  }
}

extension PreferenceKey {
  public static func _delay<T>(
    _ transform: @escaping (_PreferenceValue<Self>) -> T
  ) -> some View
    where T: View
  {
    _DelayedPreferenceView(transform: transform)
  }
}

extension View {
  public func overlayPreferenceValue<Key, T>(
    _ key: Key.Type = Key.self,
    @ViewBuilder _ transform: @escaping (Key.Value) -> T
  ) -> some View
    where Key: PreferenceKey, T: View
  {
    Key._delay { self.overlay($0._force(transform)) }
  }

  public func backgroundPreferenceValue<Key, T>(
    _ key: Key.Type = Key.self,
    @ViewBuilder _ transform: @escaping (Key.Value) -> T
  ) -> some View
    where Key: PreferenceKey, T: View
  {
    Key._delay { self.background($0._force(transform)) }
  }
}

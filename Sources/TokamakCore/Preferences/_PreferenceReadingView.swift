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

/// Delays the retrieval of a `PreferenceKey.Value` by passing the `_PreferenceValue` to a build
/// function.
public struct _DelayedPreferenceView<Key, Content>: View, _PreferenceReadingViewProtocol
  where Key: PreferenceKey, Content: View
{
  @State
  private var resolvedValue: _PreferenceValue<Key> = _PreferenceValue(storage: .init(Key.self))
  public let transform: (_PreferenceValue<Key>) -> Content

  private var valueReference: _PreferenceValue<Key>?

  public init(transform: @escaping (_PreferenceValue<Key>) -> Content) {
    self.transform = transform
  }

  public func preferenceStore(_ preferenceStore: _PreferenceStore) {
    resolvedValue = preferenceStore.value(forKey: Key.self)
  }

  public var body: some View {
    transform(valueReference ?? resolvedValue)
  }

  public static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
    let preferenceStore = inputs.preferenceStore ?? .init()
    inputs.updateContent {
      $0.valueReference = preferenceStore.value(forKey: Key.self)
    }
    return .init(
      inputs: inputs,
      preferenceStore: preferenceStore
    )
  }
}

public struct _PreferenceReadingView<Key, Content>: View where Key: PreferenceKey, Content: View {
  public let value: _PreferenceValue<Key>
  public let transform: (Key.Value) -> Content

  public init(value: _PreferenceValue<Key>, transform: @escaping (Key.Value) -> Content) {
    self.value = value
    self.transform = transform
  }

  public var body: some View {
    transform(value.value)
  }
}

public extension PreferenceKey {
  static func _delay<T>(
    _ transform: @escaping (_PreferenceValue<Self>) -> T
  ) -> some View
    where T: View
  {
    _DelayedPreferenceView(transform: transform)
  }
}

public extension View {
  func overlayPreferenceValue<Key, T>(
    _ key: Key.Type = Key.self,
    @ViewBuilder _ transform: @escaping (Key.Value) -> T
  ) -> some View
    where Key: PreferenceKey, T: View
  {
    Key._delay { self.overlay($0._force(transform)) }
  }

  func backgroundPreferenceValue<Key, T>(
    _ key: Key.Type = Key.self,
    @ViewBuilder _ transform: @escaping (Key.Value) -> T
  ) -> some View
    where Key: PreferenceKey, T: View
  {
    Key._delay { self.background($0._force(transform)) }
  }
}

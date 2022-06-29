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

public struct _PreferenceActionModifier<Key>: _PreferenceWritingModifierProtocol
  where Key: PreferenceKey, Key.Value: Equatable
{
  public let action: (Key.Value) -> ()
  public init(action: @escaping (Key.Value) -> Swift.Void) {
    self.action = action
  }

  public func body(_ content: Content, with preferenceStore: inout _PreferenceStore) -> AnyView {
    let value = preferenceStore.value(forKey: Key.self)
    let previousValue = value.reduce((value.storage.valueList as? [Key.Value] ?? []).dropLast())
    if previousValue != value.value {
      action(value.value)
    }
    return content.view
  }

  public static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
    .init(
      inputs: inputs,
      preferenceStore: inputs.preferenceStore ?? .init(),
      preferenceAction: {
        let value = $0.value(forKey: Key.self).value
        let previousValue = $0.previousValue(forKey: Key.self).value
        if value != previousValue {
          inputs.content.action(value)
        }
      }
    )
  }
}

public extension View {
  func onPreferenceChange<K>(
    _ key: K.Type = K.self,
    perform action: @escaping (K.Value) -> ()
  ) -> some View
    where K: PreferenceKey, K.Value: Equatable
  {
    modifier(_PreferenceActionModifier<K>(action: action))
  }
}

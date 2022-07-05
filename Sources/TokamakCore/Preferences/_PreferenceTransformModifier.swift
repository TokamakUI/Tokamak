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

/// Transforms a `PreferenceKey.Value`.
public struct _PreferenceTransformModifier<Key>: _PreferenceWritingModifierProtocol
  where Key: PreferenceKey
{
  public let transform: (inout Key.Value) -> ()

  public init(
    key _: Key.Type = Key.self,
    transform: @escaping (inout Key.Value) -> ()
  ) {
    self.transform = transform
  }

  public func body(_ content: Content, with preferenceStore: inout _PreferenceStore) -> AnyView {
    var newValue = preferenceStore.value(forKey: Key.self).value
    transform(&newValue)
    preferenceStore.insert(newValue, forKey: Key.self)
    return content.view
  }

  public static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
    .init(
      inputs: inputs,
      preferenceStore: inputs.preferenceStore ?? .init(),
      preferenceAction: {
        var value = $0.value(forKey: Key.self).value
        inputs.content.transform(&value)
        $0.insert(value, forKey: Key.self)
      }
    )
  }
}

public extension View {
  func transformPreference<K>(
    _ key: K.Type = K.self,
    _ callback: @escaping (inout K.Value) -> ()
  ) -> some View
    where K: PreferenceKey
  {
    modifier(_PreferenceTransformModifier<K>(transform: callback))
  }
}

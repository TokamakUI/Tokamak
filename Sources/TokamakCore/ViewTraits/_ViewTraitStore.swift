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
//  Created by Carson Katri on 7/10/21.
//

public struct _ViewTraitStore {
  public var values = [ObjectIdentifier: Any]()

  public init(values: [ObjectIdentifier: Any] = [:]) {
    self.values = values
  }

  public func value<Key>(forKey key: Key.Type = Key.self) -> Key.Value
    where Key: _ViewTraitKey
  {
    values[ObjectIdentifier(key)] as? Key.Value ?? Key.defaultValue
  }

  public mutating func insert<Key>(_ value: Key.Value, forKey key: Key.Type = Key.self)
    where Key: _ViewTraitKey
  {
    values[ObjectIdentifier(key)] = value
  }
}

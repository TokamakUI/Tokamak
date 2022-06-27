// Copyright 2022 Tokamak contributors
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
//  Created by Carson Katri on 6/20/22.
//

/// A key that stores a value that can be accessed via a `LayoutSubview`.
public protocol LayoutValueKey {
  associatedtype Value
  static var defaultValue: Self.Value { get }
}

public extension View {
  @inlinable
  func layoutValue<K>(key: K.Type, value: K.Value) -> some View where K: LayoutValueKey {
    // LayoutValueKey uses trait keys under the hood.
    _trait(_LayoutTrait<K>.self, value)
  }
}

public struct _LayoutTrait<K>: _ViewTraitKey where K: LayoutValueKey {
  public static var defaultValue: K.Value {
    K.defaultValue
  }
}

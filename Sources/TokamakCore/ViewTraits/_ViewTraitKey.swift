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

public protocol _ViewTraitKey {
  associatedtype Value
  static var defaultValue: Value { get }
}

protocol _ViewTraitWritingViewProtocol {
  func modifyViewTraitStore(_ viewTraitStore: inout _ViewTraitStore) -> AnyView
}

struct _ViewTraitWritingView<Trait, Content>: _PrimitiveView, _ViewTraitWritingViewProtocol
  where Trait: _ViewTraitKey, Content: View
{
  let value: Trait.Value
  let content: Content

  init(key _: Trait.Type = Trait.self, value: Trait.Value, _ content: Content) {
    self.value = value
    self.content = content
  }

  typealias Body = Never
  func modifyViewTraitStore(_ viewTraitStore: inout _ViewTraitStore) -> AnyView {
    viewTraitStore.insert(value, forKey: Trait.self)
    return AnyView(content)
  }
}

@frozen public struct _TraitWritingModifier<Trait>: ViewModifier
  where Trait: _ViewTraitKey
{
  public let value: Trait.Value
  @inlinable
  public init(value: Trait.Value) {
    self.value = value
  }

  public func body(content: Content) -> some View {
    _ViewTraitWritingView(key: Trait.self, value: value, content)
  }
}

public extension View {
  @inlinable
  func _trait<K>(
    _ key: K.Type,
    _ value: K.Value
  ) -> some View where K: _ViewTraitKey {
    modifier(_TraitWritingModifier<K>(value: value))
  }
}

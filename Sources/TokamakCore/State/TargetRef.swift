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

protocol TargetRefType {
  var target: Target? { get set }
}

public struct _TargetRef<V: View, T>: View, TargetRefType {
  let binding: Binding<T?>

  let view: V

  var target: Target? {
    get { binding.wrappedValue as? Target }

    set { binding.wrappedValue = newValue as? T }
  }

  public var body: V { view }
}

public extension View {
  /** Allows capturing target instance of aclosest descendant host view. The resulting instance
   is written to a given `binding`. */
  func _targetRef<T: Target>(_ binding: Binding<T?>) -> _TargetRef<Self, T> {
    .init(binding: binding, view: self)
  }
}

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
//  Created by Carson Katri on 2/15/22.
//

/// A reference type that points to a `Renderer`-specific element that has been mounted.
/// For instance, a DOM node in the `DOMFiberRenderer`.
public protocol FiberElement: AnyObject {
  associatedtype Content: FiberElementContent
  var content: Content { get }
  init(from content: Content)
  func update(with content: Content)
}

/// The data used to create an `FiberElement`.
///
/// We re-use `FiberElement` instances in the `Fiber` tree,
/// but can re-create and copy `FiberElementContent` as often as needed.
public protocol FiberElementContent: Equatable {
  init<V: View>(from primitiveView: V, useDynamicLayout: Bool)
}

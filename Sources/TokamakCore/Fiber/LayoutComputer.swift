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
//  Created by Carson Katri on 2/16/22.
//

import Foundation

/// The currently computed children.
public struct LayoutContext {
  public var children: [Child]

  public struct Child {
    public let index: Int
    public let dimensions: ViewDimensions
  }
}

/// A type that is able to propose sizes for its children.
///
/// The order of calls is guaranteed to be:
/// 1. `proposeSize(for: child1, at: 0, in: context)`
/// 2. `proposeSize(for: child2, at: 1, in: context)`
/// 3. `position(child1)`
/// 4. `position(child2)`
///
/// The `context` will contain all of the previously computed children from `proposeSize` calls.
///
/// The same `LayoutComputer` instance will be used for any given view during a single layout pass.
///
/// Sizes from `proposeSize` will be clamped, so it is safe to return negative numbers.
public protocol LayoutComputer {
  /// Will be called every time a child is evaluated.
  /// The calls will always be in order, and no more than one call will be made per child.
  func proposeSize<V: View>(for child: V, at index: Int, in context: LayoutContext) -> CGSize

  /// The child responds with their size and we place them relative to our origin.
  func position(_ child: LayoutContext.Child, in context: LayoutContext) -> CGPoint

  /// Request a size for ourself from our parent.
  func requestSize(in context: LayoutContext) -> CGSize
}

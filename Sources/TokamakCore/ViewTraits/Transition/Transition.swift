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

import Foundation

@frozen public struct AnyTransition {
  fileprivate let box: AnyTransitionBox

  private init(_ box: AnyTransitionBox) {
    self.box = box
  }
}

@usableFromInline
struct TransitionTraitKey: _ViewTraitKey {
  @inlinable static var defaultValue: AnyTransition {
    .opacity
  }

  @usableFromInline typealias Value = AnyTransition
}

@usableFromInline
struct CanTransitionTraitKey: _ViewTraitKey {
  @inlinable static var defaultValue: Bool {
    false
  }

  @usableFromInline
  typealias Value = Bool
}

public extension View {
  @inlinable
  func transition(_ t: AnyTransition) -> some View {
    _trait(TransitionTraitKey.self, t)
  }
}

public extension AnyTransition {
  static let identity: AnyTransition = .init(IdentityTransitionBox())

  static func move(edge: Edge) -> AnyTransition {
    .init(MoveTransitionBox(edge: edge))
  }

  static func asymmetric(
    insertion: AnyTransition,
    removal: AnyTransition
  ) -> AnyTransition {
    .init(AsymmetricTransitionBox(insertion: insertion.box, removal: removal.box))
  }

  static func offset(_ offset: CGSize) -> AnyTransition {
    .init(OffsetTransitionBox(offset: offset))
  }

  static func offset(
    x: CGFloat = 0,
    y: CGFloat = 0
  ) -> AnyTransition {
    offset(.init(width: x, height: y))
  }

  static var scale: AnyTransition { scale(scale: 0) }
  static func scale(scale: CGFloat, anchor: UnitPoint = .center) -> AnyTransition {
    .init(ScaleTransitionBox(scale: scale, anchor: anchor))
  }

  static let opacity: AnyTransition = .init(OpacityTransitionBox())

  static var slide: AnyTransition { .init(SlideTransitionBox()) }

  static func modifier<E>(
    active: E,
    identity: E
  ) -> AnyTransition where E: ViewModifier {
    .init(ModifierTransitionBox(active: active, identity: identity))
  }

  func combined(with other: AnyTransition) -> AnyTransition {
    .init(CombinedTransitionBox(a: box, b: other.box))
  }

//  func animation(_ animation: Animation?) -> AnyTransition
}

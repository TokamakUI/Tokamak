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

public class _AnyTransitionBox: AnyTokenBox {
  public typealias ResolvedValue = ResolvedTransition

  public struct ResolvedTransition {
    public var insertion: [Transition]
    public var removal: [Transition]
    public var insertionAnimation: Animation?
    public var removalAnimation: Animation?

    init(
      insertion: [Transition],
      removal: [Transition],
      insertionAnimation: Animation?,
      removalAnimation: Animation?
    ) {
      self.insertion = insertion
      self.removal = removal
      self.insertionAnimation = insertionAnimation
      self.removalAnimation = removalAnimation
    }

    init(transitions: [Transition]) {
      self.init(
        insertion: transitions,
        removal: transitions,
        insertionAnimation: nil,
        removalAnimation: nil
      )
    }

    public typealias Transition = (
      active: (AnyView) -> AnyView,
      identity: (AnyView) -> AnyView
    )
  }

  public func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    fatalError("implement \(#function) in subclass")
  }
}

final class IdentityTransitionBox: _AnyTransitionBox {
  override func resolve(in environment: EnvironmentValues) -> _AnyTransitionBox.ResolvedValue {
    .init(transitions: [])
  }
}

final class ConcreteTransitionBox: _AnyTransitionBox {
  let transition: ResolvedTransition.Transition

  init(_ transition: ResolvedTransition.Transition) {
    self.transition = transition
  }

  override func resolve(in environment: EnvironmentValues) -> _AnyTransitionBox.ResolvedValue {
    .init(transitions: [transition])
  }
}

final class AsymmetricTransitionBox: _AnyTransitionBox {
  let insertion: _AnyTransitionBox
  let removal: _AnyTransitionBox

  init(insertion: _AnyTransitionBox, removal: _AnyTransitionBox) {
    self.insertion = insertion
    self.removal = removal
  }

  override func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    let insertionResolved = insertion.resolve(in: environment)
    let removalResolved = removal.resolve(in: environment)
    return .init(
      insertion: insertionResolved.insertion,
      removal: removalResolved.removal,
      insertionAnimation: insertionResolved.insertionAnimation,
      removalAnimation: removalResolved.removalAnimation
    )
  }
}

final class CombinedTransitionBox: _AnyTransitionBox {
  let a: _AnyTransitionBox
  let b: _AnyTransitionBox

  init(a: _AnyTransitionBox, b: _AnyTransitionBox) {
    self.a = a
    self.b = b
  }

  override func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    let aResolved = a.resolve(in: environment)
    let bResolved = b.resolve(in: environment)
    return .init(
      insertion: aResolved.insertion + bResolved.insertion,
      removal: aResolved.removal + bResolved.removal,
      insertionAnimation: bResolved.insertionAnimation ?? aResolved.insertionAnimation,
      removalAnimation: bResolved.removalAnimation ?? aResolved.removalAnimation
    )
  }
}

final class AnimatedTransitionBox: _AnyTransitionBox {
  let animation: Animation?
  let parent: _AnyTransitionBox

  init(animation: Animation?, parent: _AnyTransitionBox) {
    self.animation = animation
    self.parent = parent
  }

  override func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    var resolved = parent.resolve(in: environment)
    resolved.insertionAnimation = animation
    resolved.removalAnimation = animation
    return resolved
  }
}

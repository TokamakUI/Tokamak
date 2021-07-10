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

public class AnyTransitionBox: AnyTokenBox {
  public typealias ResolvedValue = ResolvedTransition

  public struct ResolvedTransition {
    public let insertion: [Transition]
    public let removal: [Transition]
//    public let animation: Animation?

    init(insertion: [Transition], removal: [Transition]) {
      self.insertion = insertion
      self.removal = removal
    }

    init(transitions: [Transition]) {
      self.init(insertion: transitions, removal: transitions)
    }

    public indirect enum Transition {
      case opacity,
           slide
      case move(edge: Edge)
      case scale(scale: CGFloat, anchor: UnitPoint)
      case offset(CGSize)
      case modifier(active: (AnyView) -> AnyView, identity: (AnyView) -> AnyView)
    }
  }

  public func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    fatalError("implement \(#function) in subclass")
  }
}

class IdentityTransitionBox: AnyTransitionBox {
  override func resolve(in environment: EnvironmentValues) -> AnyTransitionBox.ResolvedValue {
    .init(transitions: [])
  }
}

class OpacityTransitionBox: AnyTransitionBox {
  override func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    .init(transitions: [.opacity])
  }
}

class SlideTransitionBox: AnyTransitionBox {
  override func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    .init(transitions: [.slide])
  }
}

class MoveTransitionBox: AnyTransitionBox {
  let edge: Edge

  init(edge: Edge) {
    self.edge = edge
  }

  override func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    .init(transitions: [.move(edge: edge)])
  }
}

class ScaleTransitionBox: AnyTransitionBox {
  let scale: CGFloat
  let anchor: UnitPoint

  init(scale: CGFloat, anchor: UnitPoint) {
    self.scale = scale
    self.anchor = anchor
  }

  override func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    .init(transitions: [.scale(scale: scale, anchor: anchor)])
  }
}

class OffsetTransitionBox: AnyTransitionBox {
  let offset: CGSize

  init(offset: CGSize) {
    self.offset = offset
  }

  override func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    .init(transitions: [.offset(offset)])
  }
}

class ModifierTransitionBox<E>: AnyTransitionBox
  where E: ViewModifier
{
  let active: E
  let identity: E

  init(active: E, identity: E) {
    self.active = active
    self.identity = identity
  }

  override func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    .init(transitions: [.modifier(active: {
      AnyView($0.modifier(self.active))
    }, identity: {
      AnyView($0.modifier(self.identity))
    })])
  }
}

class AsymmetricTransitionBox: AnyTransitionBox {
  let insertion: AnyTransitionBox
  let removal: AnyTransitionBox

  init(insertion: AnyTransitionBox, removal: AnyTransitionBox) {
    self.insertion = insertion
    self.removal = removal
  }

  override func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    .init(
      insertion: insertion.resolve(in: environment).insertion,
      removal: removal.resolve(in: environment).removal
    )
  }
}

class CombinedTransitionBox: AnyTransitionBox {
  let a: AnyTransitionBox
  let b: AnyTransitionBox

  init(a: AnyTransitionBox, b: AnyTransitionBox) {
    self.a = a
    self.b = b
  }

  override func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    .init(
      insertion: a.resolve(in: environment).insertion + b.resolve(in: environment).insertion,
      removal: a.resolve(in: environment).removal + b.resolve(in: environment).removal
    )
  }
}

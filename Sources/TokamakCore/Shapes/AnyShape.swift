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

import Foundation

protocol AnyShapeBox {
  var animatableDataBox: _AnyAnimatableData { get set }

  func path(in rect: CGRect) -> Path

  func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize
}

private struct ConcreteAnyShapeBox<Base: Shape>: AnyShapeBox {
  var base: Base

  var animatableDataBox: _AnyAnimatableData {
    get {
      _AnyAnimatableData(base.animatableData)
    }
    set {
      guard let newData = newValue.value as? Base.AnimatableData else {
        // TODO: Should this crash?
        return
      }

      base.animatableData = newData
    }
  }

  func path(in rect: CGRect) -> Path {
    base.path(in: rect)
  }

  func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
    base.sizeThatFits(proposal)
  }
}

public struct AnyShape: Shape {
  var box: AnyShapeBox

  private init(_ box: AnyShapeBox) {
    self.box = box
  }
}

public extension AnyShape {
  init<S: Shape>(_ shape: S) {
    box = ConcreteAnyShapeBox(base: shape)
  }

  func path(in rect: CGRect) -> Path {
    box.path(in: rect)
  }

  func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
    box.sizeThatFits(proposal)
  }

  var animatableData: _AnyAnimatableData {
    get { box.animatableDataBox }
    set { box.animatableDataBox = newValue }
  }
}

// Copyright 2021 Tokamak contributors
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
//  Created by Carson Katri on 5/24/22.
//

import Foundation

/// Measures the bounds of the `Text` with modifiers and wrapping inside the `proposedSize`.
final class TextLayoutComputer: LayoutComputer {
  let text: Text
  let proposedSize: CGSize
  let environment: EnvironmentValues

  init(text: Text, proposedSize: CGSize, environment: EnvironmentValues) {
    self.text = text
    self.proposedSize = proposedSize
    self.environment = environment
  }

  func proposeSize<V>(for child: V, at index: Int, in context: LayoutContext) -> CGSize
    where V: View
  {
    fatalError("Text views cannot have children.")
  }

  func position(_ child: LayoutContext.Child, in context: LayoutContext) -> CGPoint {
    fatalError("Text views cannot have children.")
  }

  func requestSize(in context: LayoutContext) -> CGSize {
    environment.measureText(text, proposedSize, environment)
  }
}

public extension Text {
  static func _makeView(_ inputs: ViewInputs<Text>) -> ViewOutputs {
    .init(
      inputs: inputs,
      layoutComputer: { proposedSize in
        TextLayoutComputer(
          text: inputs.view,
          proposedSize: proposedSize,
          environment: inputs.environment.environment
        )
      }
    )
  }
}

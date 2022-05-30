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

import Foundation
import TokamakShim

struct StackDemo: View {
  @State
  private var horizontalSpacing: CGFloat = 8

  @State
  private var verticalSpacing: CGFloat = 8

  var body: some View {
    VStack(spacing: verticalSpacing) {
      Text("Horizontal Spacing")
      Slider(value: $horizontalSpacing, in: 0...100)

      Text("Vertical Spacing")
      Slider(value: $verticalSpacing, in: 0...100)
      HStack(spacing: horizontalSpacing) {
        Rectangle()
          .fill(Color.red)
          .frame(width: 100, height: 100)

        Rectangle()
          .fill(Color.green)
          .frame(width: 100, height: 100)
      }
    }
  }
}

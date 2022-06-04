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
//  Created by Carson Katri on 7/9/21.
//

import TokamakShim

struct ProgressViewDemo: View {
  @State
  private var progress = 0.5

  var body: some View {
    VStack {
      HStack { Spacer() }

      ProgressView("Indeterminate")
      ProgressView(value: progress) {
        Text("Determinate")
      } currentValueLabel: {
        Text("\(progress)")
      }
      ProgressView("Increased Total", value: progress, total: 2)
      Button("Make Progress") { progress += 0.1 }
    }
  }
}

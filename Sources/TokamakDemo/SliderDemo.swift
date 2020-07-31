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

import TokamakShim

struct SliderDemo: View {
  @State private var value: Double = 0
  @State private var editing = false

  var body: some View {
    VStack {
      Slider(
        value: $value,
        in: 0...1,
        step: 0.1,
        onEditingChanged: { editing = $0; print($0) },
        minimumValueLabel: Text("min"),
        maximumValueLabel: Text("max")
      ) {
        Text("label")
      }
      Text("Value: \(value)")
      Text(editing ? "Editing" : "Not editing")
    }
  }
}

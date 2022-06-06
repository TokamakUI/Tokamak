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

struct Title: View {
  init(_ title: String) {
    self.title = title
  }

  let title: String
  var body: some View {
    HStack {
      Text(title).font(.headline)
      Spacer()
    }
  }
}

struct SliderDemo: View {
  @State
  private var value: Double = 0

  @State
  private var value2: Double = 0

  @State
  private var value3: Double = 0

  @State
  private var value4: Double = 0

  @State
  private var editing = false

  var body: some View {
    ScrollView(.vertical) {
      Group {
        Title("Basic slider")
        Slider(value: $value)
        Text("Value: \(value)")
      }
      Group {
        Title("Labelled slider")
        Slider(value: $value) {
          Text("label")
        }
        Text("Value: \(value)")
      }
      Group {
        Title("Steps, labels, and editing tracking")
        Slider(
          value: $value2,
          in: 0...1,
          step: 0.1,
          onEditingChanged: { editing = $0; print($0) },
          minimumValueLabel: Text("min"),
          maximumValueLabel: Text("max")
        ) {
          Text("label")
        }
        Text("Value: \(value2)")
        Text(editing ? "Editing" : "Not editing")
      }
      Group {
        Title("Non-integer step count")
        Text("First slider has steps at 0.3, 0.6, 0.9; second one has stops every 1/3 of the way")
        Slider(value: $value3, in: 0...1, step: 0.3)
        Slider(value: $value4, in: 0...3, step: 1)
      }
    }
  }
}

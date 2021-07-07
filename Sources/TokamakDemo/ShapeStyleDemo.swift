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

@available(macOS 12.0, iOS 15.0, *)
struct ShapeStyleDemo: View {
  var body: some View {
    HStack {
      VStack {
        Text("Red Style")
        Rectangle()
          .frame(width: 25, height: 25)
      }
      .foregroundStyle(Color.red)
      VStack {
        Text("Green Style")
        Rectangle()
          .frame(width: 25, height: 25)
      }
      .foregroundStyle(Color.green)
      VStack {
        Text("Blue Style")
        Rectangle()
          .frame(width: 25, height: 25)
      }
      .foregroundStyle(Color.blue)
    }
  }
}

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

struct PressedButtonStyle: ButtonStyle {
  let pressedColor: Color

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundColor(configuration.isPressed ? pressedColor : .blue)
      .padding(15)
  }
}

public struct ButtonStyleDemo: View {
  public var body: some View {
    VStack {
      Button("Default Style") {
        print("tapped")
      }
      Button("Pressed Button Style") {
        print("tapped")
      }
      .buttonStyle(
        PressedButtonStyle(pressedColor: Color.red)
      )
    }
  }
}

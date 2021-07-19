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
  var allSizes: some View {
    HStack {
      if #available(iOS 15.0, macOS 12.0, *) {
        ForEach(Array(ControlSize.allCases.enumerated()), id: \.offset) { controlSize in
          VStack {
            Button("Button", role: .cancel) {}
              .controlSize(controlSize.element)
          }
        }
      }
    }
  }

  public var body: some View {
    VStack {
      Button("Default Style") {
        print("tapped")
      }
      Button(action: { print("tapped") }, label: {
        HStack {
          Text("Default").padding(.trailing, 5)
          Circle().frame(width: 10, height: 10, alignment: .center)
          Text("Style").padding(.horizontal, 5)
          Ellipse().fill(Color.red).frame(width: 20, height: 10, alignment: .center)
          Text("With").padding(.horizontal, 5)
          Capsule().fill(Color.green).frame(width: 20, height: 10, alignment: .center)
          Text("Complex").padding(.horizontal, 5)
          Rectangle().fill(Color.blue).frame(width: 10, height: 10, alignment: .center)
          Text("Label").padding(.leading, 5)
        }
      })
      Button("Pressed Button Style") {
        print("tapped")
      }
      .buttonStyle(
        PressedButtonStyle(pressedColor: Color.red)
      )
      Button(action: { print("tapped") }, label: {
        HStack {
          Text("Pressed").padding(.trailing, 5)
          Circle().frame(width: 10, height: 10, alignment: .center)
          Text("Style").padding(.horizontal, 5)
          Ellipse().fill(Color.red).frame(width: 20, height: 10, alignment: .center)
          Text("With").padding(.horizontal, 5)
          Capsule().fill(Color.green).frame(width: 20, height: 10, alignment: .center)
          Text("Complex").padding(.horizontal, 5)
          Rectangle().fill(Color.blue).frame(width: 10, height: 10, alignment: .center)
          Text("Label").padding(.leading, 5)
        }
      })
        .buttonStyle(
          PressedButtonStyle(pressedColor: Color.red)
        )
      if #available(iOS 15.0, macOS 12.0, *) {
        Button("Prominent") {}
          .controlProminence(.increased)
        VStack {
          Text("automatic")
            .font(.headline)
          allSizes
            .buttonStyle(DefaultButtonStyle())
          Text("borderless")
            .font(.headline)
          allSizes
            .buttonStyle(BorderlessButtonStyle())
          Text("bordered")
            .font(.headline)
          allSizes
            .buttonStyle(BorderedButtonStyle())
          Text("link")
            .font(.headline)
          allSizes
            .buttonStyle(LinkButtonStyle())
          Text("plain")
            .font(.headline)
          allSizes
            .buttonStyle(PlainButtonStyle())
        }
      }
    }
  }
}

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
//  Created by Carson Katri on 11/26/20.
//

import TokamakShim

struct TestPreferenceKey: PreferenceKey {
  static let defaultValue = Color.red
  static func reduce(value: inout Color, nextValue: () -> Color) {
    value = nextValue()
  }
}

struct PreferenceKeyDemo: View {
  @State
  private var testKeyValue: Color = .yellow

  @Environment(\.colorScheme)
  var colorScheme

  var body: some View {
    VStack {
      Group {
        Text("Preferences are like reverse-environment values.")
        Text(
          """
          In this demo, the background color of each item \
          is set to the value of the PreferenceKey.
          """
        )
        Text("Default color: red (this won't show on the innermost because it never 'changed').")
        Text("Innermost child sets the color to blue.")
        Text("One level up sets the color to green, and so on.")

        VStack {
          Text("Root")
            .padding(.bottom, 8)
          SetColor(3, .purple) {
            SetColor(2, .green) {
              SetColor(1, .blue)
            }
          }
        }
        .padding()
        .background(testKeyValue)
        .onPreferenceChange(TestPreferenceKey.self) {
          print("Value changed to \($0)")
          testKeyValue = $0
        }
      }

      Group {
        Text("Preferences can also be accessed and used immediately via a background or overlay:")
        Circle()
          .frame(width: 25, height: 25)
          .foregroundColor(testKeyValue)
          .backgroundPreferenceValue(TestPreferenceKey.self) {
            Circle()
              .frame(width: 50, height: 50)
              .foregroundColor($0)
          }
        Circle()
          .frame(width: 50, height: 50)
          .foregroundColor(testKeyValue)
          .overlayPreferenceValue(TestPreferenceKey.self) {
            Circle()
              .frame(width: 25, height: 25)
              .foregroundColor($0)
          }
      }

      Group {
        Text(
          """
          We can also transform the key. Here we perform several transformations and use an \
          `overlayPreferenceValue`
          """
        )
        Text("1. Set the color to yellow")
        Text("2. Transform if the color is yellow -> green")
        Text("3. Transform if the color is green -> blue")
        Text("4. Use the final color in an overlay.")
        Circle()
          .frame(width: 50, height: 50)
          .foregroundColor(testKeyValue)
          .preference(key: TestPreferenceKey.self, value: .yellow)
          .transformPreference(TestPreferenceKey.self) {
            print("Transforming \($0) ->? green")
            if $0 == .yellow {
              $0 = .green
            }
          }
          .transformPreference(TestPreferenceKey.self) {
            print("Transforming \($0) ->? blue")
            if $0 == .green {
              $0 = .blue
            }
          }
          .overlayPreferenceValue(TestPreferenceKey.self) { newColor in
            Circle()
              .frame(width: 25, height: 25)
              .foregroundColor(newColor)
          }
      }
    }
  }

  struct SetColor<Content: View>: View {
    let level: Int
    let color: Color
    let content: Content

    @State
    private var testKeyValue: Color = .yellow

    init(_ level: Int, _ color: Color, @ViewBuilder _ content: () -> Content) {
      self.level = level
      self.color = color
      self.content = content()
    }

    var body: some View {
      VStack {
        Text("Level \(level)")
          .padding(.bottom, level == 1 ? 0 : 8)
        content
      }
      .padding()
      .background(testKeyValue)
      .onPreferenceChange(TestPreferenceKey.self) {
        testKeyValue = $0
      }
      .preference(key: TestPreferenceKey.self, value: color)
    }
  }
}

extension PreferenceKeyDemo.SetColor where Content == EmptyView {
  init(_ level: Int, _ color: Color) {
    self.init(level, color) { EmptyView() }
  }
}

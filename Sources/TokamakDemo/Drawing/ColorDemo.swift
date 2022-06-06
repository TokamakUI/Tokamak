// Copyright 2019-2020 Tokamak contributors
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
//  Created by Carson Katri on 7/12/20.
//

import TokamakShim

public struct ColorDemo: View {
  var color: Color {
    guard let v0d = Double(v0),
          let v1d = Double(v1),
          let v2d = Double(v2)
    else {
      return .white
    }
    switch colorForm {
    case .rgb:
      return Color(red: v0d, green: v1d, blue: v2d)
    case .hsb:
      return Color(hue: v0d, saturation: v1d, brightness: v2d)
    }
  }

  enum ColorForm: String {
    case rgb, hsb
  }

  let colors: [(String, Color)] = [
    ("Clear", .clear),
    ("Black", .black),
    ("White", .white),
    ("Gray", .gray),
    ("Red", .red),
    ("Green", .green),
    ("Blue", .blue),
    ("Orange", .orange),
    ("Yellow", .yellow),
    ("Pink", .pink),
    ("Purple", .purple),
    ("Primary", .primary),
    ("Secondary", .secondary),
  ]

  @State
  private var colorForm: ColorForm = .hsb

  @State
  private var v0: String = "0.9"

  @State
  private var v1: String = "1"

  @State
  private var v2: String = "0.5"

  public var body: some View {
    ScrollView {
      VStack {
        Button("Input \(colorForm.rawValue.uppercased())") {
          colorForm = colorForm == .rgb ? .hsb : .rgb
        }
        TextField(colorForm == .rgb ? "Red" : "Hue", text: $v0)
        TextField(colorForm == .rgb ? "Green" : "Saturation", text: $v1)
        TextField(colorForm == .rgb ? "Blue" : "Brightness", text: $v2)
        Text("\(v0) \(v1) \(v2)")
          .bold()
          .padding()
          .background(color)
        Text("Accent Color: \(String(describing: Color.accentColor))")
          .bold()
          .padding()
          .background(Color.accentColor)
        ForEach(colors, id: \.0) {
          Text($0.0)
            .font(.caption)
            .bold()
            .padding()
            .background($0.1)
        }
      }.padding(.horizontal)
    }
  }
}

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
//  Created by Carson Katri on 7/11/21.
//

import Foundation
import TokamakShim

struct AnimationDemo: View {
  @State
  private var delay: Double = 0

  @State
  private var speed: Double = 1

  @State
  private var on = false

  enum AnimationStyle: String, Identifiable, CaseIterable {
    case easeIn, easeOut, easeInOut, spring

    var id: RawValue { rawValue }
    var animation: Animation {
      switch self {
      case .easeIn: return .easeIn(duration: 5)
      case .easeOut: return .easeOut(duration: 5)
      case .easeInOut: return .easeInOut(duration: 5)
      case .spring: return .spring()
      }
    }
  }

  var withAnimationDemo: some View {
    VStack {
      Text("withAnimation")
        .font(.headline)
      Circle()
        .fill(on ? Color.green : .red)
        .frame(width: on ? 100 : 50, height: on ? 100 : 50)
      Slider(value: $delay, in: 0...3) {
        Text("Delay")
      }
      Slider(value: $speed, in: 1...2) {
        Text("Speed")
      }
      Button("Toggle with Animation") {
        withAnimation(
          Animation.default.delay(delay).speed(speed)
        ) {
          on = !on
        }
      }
      Button("Toggle without Animation") {
        on = !on
      }
    }
  }

  var easingDemo: some View {
    VStack(alignment: .leading) {
      Text("Styles")
        .font(.headline)
      Rectangle()
        .fill(Color.gray)
        .frame(width: 100, height: 10)
      ForEach(AnimationStyle.allCases) {
        Text(".\($0.rawValue)")
          .font(.system(.caption, design: .monospaced))
        Rectangle()
          .fill(on ? Color.green : .red)
          .frame(width: 10, height: 10)
          .offset(x: on ? 100 : 0)
          .animation($0.animation, value: on)
      }
    }
  }

  @State
  private var foreverAnimation = false

  var repeatedAnimationDemo: some View {
    VStack {
      Text("Repeated Animation")
        .font(.headline)
      ZStack {
        Circle()
          .fill(foreverAnimation ? Color.green : .red)
          .frame(width: foreverAnimation ? 50 : 100, height: foreverAnimation ? 50 : 100)
      }
      .frame(width: 100, height: 100)
      Button("Start") {
        withAnimation(Animation.default.repeatForever()) {
          foreverAnimation = !foreverAnimation
        }
      }
    }
  }

  var body: some View {
    HStack {
      withAnimationDemo
      easingDemo
      repeatedAnimationDemo
    }
  }
}

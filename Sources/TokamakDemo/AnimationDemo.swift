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
  @State private var animation: AnimationStyle = .easeIn
  @State private var delay: Double = 0
  @State private var speed: Double = 1
  @State private var on = false

  enum AnimationStyle: Hashable, Identifiable {
    case easeIn, easeOut, easeInOut, spring

    var id: Int { hashValue }
    var animation: Animation {
      switch self {
      case .easeIn: return .easeIn
      case .easeOut: return .easeOut
      case .easeInOut: return .easeInOut
      case .spring: return .spring()
      }
    }
  }

  var withAnimationDemo: some View {
    VStack {
      Text("withAnimation")
        .font(.headline)
      HStack {
        VStack {
          Text("on withAnimation")
            .font(.caption)
          Circle()
            .fill(on ? Color.green : .red)
            .frame(width: on ? 50 : 100, height: on ? 50 : 100)
        }
        VStack {
          Text("on value change")
            .font(.caption)
          Circle()
            .fill(on ? Color.green : .red)
            .frame(width: on ? 50 : 100, height: on ? 50 : 100)
            .animation(animation.animation, value: on)
        }
      }
      Picker("Animation", selection: $animation) {
        ForEach([
          AnimationStyle.easeIn,
          AnimationStyle.easeOut,
          AnimationStyle.easeInOut,
          AnimationStyle.spring,
        ]) {
          Text(String(describing: $0))
        }
      }
      Text("Delay")
      Slider(value: $delay, in: 0...3)
      Text("Speed")
      Slider(value: $speed, in: 1...2)
      Button("Toggle with Animation") {
        withAnimation(animation.animation.delay(delay).speed(speed)) {
          on = !on
        }
      }
      Button("Toggle without Animation") {
        on = !on
      }
    }
  }

  @State private var foreverAnimation = false

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
//    Circle()
//      .fill(on ? Color.red : Color.green)
//      .frame(width: 100, height: 100)
//      .animation(.easeInOut, value: on)
//    Button("Toggle") {
//      on = !on
//    }
    HStack {
      withAnimationDemo
      repeatedAnimationDemo
    }
  }
}

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
//  Created by Carson Katri on 7/13/21.
//

import TokamakShim

private struct ColorOverlayModifier: ViewModifier {
  var color: Color

  func body(content: Content) -> some View {
    content
      .background(color)
  }
}

struct TransitionDemo: View {
  @State
  private var isVisible = false

  @State
  private var isInnerVisible = false

  var body: some View {
    VStack {
      Button(isVisible ? "Hide" : "Show") {
        withAnimation(.easeInOut(duration: 3)) {
          isVisible.toggle()
        }
      }
      if isVisible {
        Text(".opacity")
          .transition(AnyTransition.opacity)
        Text(".offset(x: 100, y: 100)")
          .transition(AnyTransition.offset(x: 100, y: 100))
        Text(".move(edge: .leading)")
          .transition(AnyTransition.move(edge: .leading))
        Text(".slide")
          .transition(AnyTransition.slide)
        Text(".scale")
          .transition(AnyTransition.scale)
        Text(".opacity/.scale")
          .transition(AnyTransition.asymmetric(insertion: .opacity, removal: .scale))
        Text(".opacity + .slide")
          .transition(AnyTransition.opacity.combined(with: .slide))
        Text(".modifier")
          .transition(AnyTransition.modifier(
            active: ColorOverlayModifier(color: .red),
            identity: ColorOverlayModifier(color: .clear)
          ))
        Text(".animation")
          .transition(AnyTransition.scale.animation(.spring()))
        VStack {
          Text("Grouped Transition")
          Button(isInnerVisible ? "Hide Inner" : "Show Inner") {
            withAnimation(.easeInOut(duration: 3)) { isInnerVisible.toggle() }
          }
          Text(".slide").transition(AnyTransition.slide)
          if isInnerVisible {
            Text(".slide").transition(AnyTransition.slide)
          }
        }
        .transition(AnyTransition.slide)
      }
    }
  }
}

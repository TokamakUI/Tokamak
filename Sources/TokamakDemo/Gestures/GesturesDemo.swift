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
//  Created by Szymon on 26/8/2023.
//

import Foundation
import TokamakShim

struct GesturesDemo: View {
  @State
  var count: Int = 0
  @State
  var countDouble: Int = 0
  @GestureState
  var isDetectingTap = false

  @GestureState
  var isDetectingLongPress = false
  @State
  var completedLongPress = false
  @State
  var countLongpress: Int = 0

  @GestureState
  var dragAmount = CGSize.zero
  @State
  private var countDragLongPress = 0

  var body: some View {
    HStack(alignment: .top, spacing: 8) {
      tapGestures
      longPressGestures
      dragGestures
    }
    .padding()
  }

  var dragGestures: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Drag Gestures")

      HStack {
        Rectangle()
          .fill(Color.yellow)
          .frame(width: 100, height: 100)
          .gesture(DragGesture().updating($dragAmount) { value, state, _ in
            state = value.translation
          }.onEnded { value in
            print(value)
          })
        Text("dragAmount: \(dragAmount.width), \(dragAmount.height)")
      }

      HStack {
        Rectangle()
          .fill(Color.red)
          .frame(width: 100, height: 100)
          .gesture(
            DragGesture(minimumDistance: 0)
              .onChanged { _ in
                countDragLongPress += 1
              }
          )
        Text("Drag Count: \(countDragLongPress)")
      }
    }
  }

  var longPressGestures: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("LongPress Gestures")

      HStack {
        Rectangle()
          .fill(
            isDetectingLongPress ? Color
              .pink : (completedLongPress ? Color.purple : Color.gray)
          )
          .frame(width: 100, height: 100)
          .gesture(
            LongPressGesture(minimumDuration: 2)
              .updating($isDetectingLongPress) { currentState, gestureState, transaction in
                gestureState = currentState
                transaction.animation = Animation.easeIn(duration: 2.0)
              }
              .onEnded { finished in
                completedLongPress = finished
              }
          )
        Text(
          isDetectingLongPress ? "detecting" :
            (completedLongPress ? "completed" : "unknow")
        )
      }

      HStack {
        Rectangle()
          .fill(Color.orange)
          .frame(width: 100, height: 100)
          .onLongPressGesture(minimumDuration: 0) {
            countLongpress += 1
          }
          .onTapGesture {
            fatalError("onTapGesture, should not be called")
          }
        Text("Long Pressed: \(countLongpress)")
      }
    }
  }

  var tapGestures: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Tap Gestures")
      HStack {
        Rectangle()
          .fill(Color.white)
          .frame(width: 100, height: 100)
          .onTapGesture {
            count += 1
            print("⚪️ gesture")
          }
        Text("Tap: \(count)")
      }
      HStack {
        Rectangle()
          .fill(Color.green)
          .frame(width: 100, height: 100)
          .onTapGesture(count: 2) {
            countDouble += 1
            print("🟢 double gesture")
          }
        Text("double tap: \(countDouble)")
      }
      HStack {
        Rectangle()
          .fill(Color.blue)
          .frame(width: 100, height: 100)
          .onTapGesture {
            print("🔵 1st gesture")
          }
          .onTapGesture {
            fatalError("should not be called")
          }
        Text("1st tap gesture")
      }
      HStack {
        Rectangle()
          .fill(Color.pink)
          .frame(width: 100, height: 100)
          .simultaneousGesture(
            TapGesture()
              .onEnded { _ in
                print("🩷 simultaneousGesture gesture")
              }
          )
          .onTapGesture {
            fatalError("should not be called")
          }
          .onTapGesture {
            fatalError("should not be called")
          }
          .simultaneousGesture(
            TapGesture()
              .onEnded { _ in
                print("🩷 simultaneousGesture 2 gesture")
              }
          )
        Text("simultaneousGesture")
      }
      HStack {
        Rectangle()
          .fill(Color.purple)
          .frame(width: 100, height: 100)
          .simultaneousGesture(
            TapGesture()
              .onEnded { _ in
                fatalError("should not be called")
              }
          )
          .onTapGesture {
            fatalError("should not be called")
          }
          .highPriorityGesture(
            TapGesture()
              .onEnded { _ in
                fatalError("should not be called")
              }
          )
          .highPriorityGesture(
            TapGesture()
              .onEnded { _ in
                print("🟣 highPriorityGesture 3 gesture")
              }
          )
        Text("highPriorityGesture")
      }
    }
  }
}

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

import TokamakShim

struct GestureCoordinateSpaceDemo: View {
  let rows = 16
  let columns = 16

  struct Rect: Hashable {
    let row: Int
    let column: Int
  }

  @State
  private var selectedRects: Set<Rect> = []

  var body: some View {
    VStack(spacing: 0) {
      ForEach(0..<rows, id: \.self) { row in
        HStack(spacing: 0) {
          ForEach(0..<columns, id: \.self) { column in
            Rectangle()
              .fill(isSelected(row: row, column: column) ? Color.blue : Color.gray)
              .frame(width: 50, height: 50)
              .overlay(
                Text("\(row):\(column)")
                  .foregroundColor(.white)
              )
          }
        }
      }
    }
    .coordinateSpace(name: "MyView")
    .gesture(
      TapGesture()
        .onEnded {
          selectedRects.removeAll()
        }
    )
    .gesture(
      DragGesture(coordinateSpace: .named("MyView"))
        .onChanged { value in
          let location = value.location
          let row = Int(location.y / 50)
          let column = Int(location.x / 50)
          if !isSelected(row: row, column: column) {
            selectedRects.insert(Rect(row: row, column: column))
          }
        }
    )
  }

  func isSelected(row: Int, column: Int) -> Bool {
    selectedRects.contains(Rect(row: row, column: column))
  }
}

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

import TokamakDOM

struct Star: Shape {
  func path(in rect: CGRect) -> Path {
    Path { path in
      path.move(to: .init(x: 40, y: 0))
      path.addLine(to: .init(x: 20, y: 76))
      path.addLine(to: .init(x: 80, y: 30.4))
      path.addLine(to: .init(x: 0, y: 30.4))
      path.addLine(to: .init(x: 64, y: 76))
      path.addLine(to: .init(x: 40, y: 0))
      print(path)
    }
  }
}

struct PathDemo: View {
  var body: some View {
    VStack {
      Star()
        .fill(Color(0xFFD000))
      Path { path in
        path.addRect(.init(origin: .zero, size: .init(width: 20, height: 20)))
        path.addEllipse(in: .init(origin: .init(x: 25, y: 0),
                                  size: .init(width: 20, height: 20)))
        path.addRoundedRect(in: .init(origin: .init(x: 50, y: 0),
                                      size: .init(width: 20, height: 20)),
                            cornerSize: .init(width: 4, height: 4))
        path.addArc(center: .init(x: 85, y: 10),
                    radius: 10,
                    startAngle: .degrees(90),
                    endAngle: .degrees(180),
                    clockwise: true)
      }
      .stroke(Color(0xFFD000), lineWidth: 4)
      .padding(.vertical)
    }
  }
}

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

struct PathDemo: View {
  var body: some View {
    Path { path in
//      path.move(to: .init(x: 20, y: 0))
//      path.addLine(to: .init(x: 10, y: 38))
//      path.addLine(to: .init(x: 40, y: 15.2))
//      path.addLine(to: .init(x: 0, y: 15.2))
//      path.addLine(to: .init(x: 32, y: 38))
//      path.addLine(to: .init(x: 20, y: 0))
//      path.addRect(.init(.init(x: 5, y: 5), .init(width: 10, height: 10)))
//      path.addEllipse(in: .init(.init(x: 35, y: 5), .init(width: 5, height: 5)))
//      path.addRoundedRect(in: .init(.init(x: 5, y: 33), .init(width: 10, height: 10)),
//                          cornerSize: .init(width: 2, height: 2))
//      path.move(to: .init(x: 35, y: 33))
//      path.addArc(center: .init(x: 40, y: 38),
//                  radius: 5,
//                  startAngle: .degrees(90),
//                  endAngle: .degrees(180),
//                  clockwise: false)
      path.addArc(center: .init(x: 50, y: 50),
                  radius: 50,
                  startAngle: .degrees(90),
                  endAngle: .degrees(180),
                  clockwise: false)
    }
    .stroke(Color(0xFFD000))
//    HTML("svg", ["width": "100%", "height": "100%"]) {
//      HTML("circle", [
//        "cx": "50%", "cy": "50%", "r": "40%",
//        "stroke": "green", "stroke-width": "4", "fill": "yellow",
//      ])
//    }
  }
}

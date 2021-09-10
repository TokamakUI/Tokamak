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

@available(macOS 12.0, iOS 15.0, *)
struct ShapeStyleDemo: View {
  var body: some View {
    #if compiler(>=5.5) || os(WASI)
    VStack {
      HStack {
        VStack {
          Text("Red Style")
          Rectangle()
            .frame(width: 25, height: 25)
        }
        .foregroundStyle(Color.red)
        VStack {
          Text("Green Style")
          Rectangle()
            .frame(width: 25, height: 25)
        }
        .foregroundStyle(Color.green)
        VStack {
          Text("Blue Style")
          Rectangle()
            .frame(width: 25, height: 25)
        }
        .foregroundStyle(Color.blue)
      }
      ZStack {
        HStack(spacing: 0) {
          Rectangle()
            .foregroundStyle(Color.red)
            .frame(width: 60, height: 100)
          Rectangle()
            .foregroundStyle(Color.orange)
            .frame(width: 60, height: 100)
          Rectangle()
            .foregroundStyle(Color.yellow)
            .frame(width: 60, height: 100)
          Rectangle()
            .foregroundStyle(Color.green)
            .frame(width: 60, height: 100)
          Rectangle()
            .foregroundStyle(Color.blue)
            .frame(width: 60, height: 100)
          Rectangle()
            .foregroundStyle(Color.purple)
            .frame(width: 60, height: 100)
        }
        VStack(spacing: 0) {
          HStack {
            Text("Ultra Thin")
            Spacer()
          }
          .background(Material.ultraThin)
          HStack {
            Text("Thin")
            Spacer()
          }
          .background(Material.thin)
          HStack {
            Text("Regular")
            Spacer()
          }
          .background(Material.regular)
          HStack {
            Text("Thick")
            Spacer()
          }
          .background(Material.thick, in: Rectangle())
          HStack {
            Text("Ultra Thick")
            Spacer()
          }
          .background(Material.ultraThick, in: Rectangle())
        }
      }
    }
    HStack {
      VStack {
        Text("Primary")
          .foregroundStyle(HierarchicalShapeStyle.primary)
        Text("Secondary")
          .foregroundStyle(HierarchicalShapeStyle.secondary)
        Text("Tertiary")
          .foregroundStyle(HierarchicalShapeStyle.tertiary)
        Text("Quaternary")
          .foregroundStyle(HierarchicalShapeStyle.quaternary)
      }
      VStack {
        Text("Primary")
          .foregroundStyle(HierarchicalShapeStyle.primary)
        Text("Secondary")
          .foregroundStyle(HierarchicalShapeStyle.secondary)
        Text("Tertiary")
          .foregroundStyle(HierarchicalShapeStyle.tertiary)
        Text("Quaternary")
          .foregroundStyle(HierarchicalShapeStyle.quaternary)
      }
      .foregroundStyle(Color.red, Color.green, Color.blue)
    }
    VStack {
      Rectangle()
        .fill(
          LinearGradient(
            colors: [.red, .green, .blue],
            startPoint: .bottomLeading,
            endPoint: .topTrailing
          )
        )
        .frame(width: 300, height: 100)
      Rectangle()
        .fill(
          RadialGradient(
            colors: [.red, .green, .blue],
            center: .topLeading,
            startRadius: 50,
            endRadius: 100
          )
        )
        .frame(width: 300, height: 100)
      Rectangle()
        .fill(
          AngularGradient(
            colors: [.red, .green, .blue],
            center: UnitPoint(x: 0.25, y: 0.25),
            startAngle: .degrees(45),
            endAngle: .degrees(130)
          )
        )
        .frame(width: 300, height: 100)
    }
    #endif
  }
}

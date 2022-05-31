// Copyright 2021 Tokamak contributors
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
//  Created by Carson Katri on 9/19/21.
//

import Foundation
import TokamakShim

@available(macOS 12.0, iOS 15.0, *)
public struct CanvasDemo: View {
  public var body: some View {
    Confetti()
  }
}

@available(macOS 12.0, iOS 15.0, *)
struct Confetti: View {
  static let colors: [Color] = [
    Color.red,
    Color.green,
    Color.blue,
    Color.pink,
    Color.purple,
    Color.orange,
    Color.yellow,
  ]
  @State
  private var startDate = Date()
  private let pieces: [Piece] = (0..<50).map { _ in
    Piece(
      point: CGPoint(x: CGFloat.random(in: 0...1), y: CGFloat.random(in: 0...1)),
      size: CGSize(width: CGFloat.random(in: 0...1), height: CGFloat.random(in: 0...1)),
      initialVelocity: CGSize(
        width: -CGFloat.random(in: -1...1),
        height: CGFloat.random(in: 0...2)
      ),
      angularVelocity: Double.random(in: -1...1),
      color: Self.colors.randomElement()!
    )
  }

  struct Piece {
    let point: CGPoint
    let size: CGSize
    let initialVelocity: CGSize
    let angularVelocity: Double
    let color: Color
  }

  static let shape = Rectangle()

  var body: some View {
    TimelineView(AnimationTimelineSchedule.animation) { timeline in
      Canvas { context, size in
        let elapsed = CGFloat(
          timeline.date.timeIntervalSince1970 - startDate
            .timeIntervalSince1970
        ).truncatingRemainder(dividingBy: 4) * 10
        let sqElapsed = elapsed * elapsed

        for piece in pieces {
          context.drawLayer { context in
            context.translateBy(
              x: (piece.point.x * size.width) + (piece.initialVelocity.width * sqElapsed),
              y: -((1 + piece.point.y) * (size.height / 2)) + (1 + piece.initialVelocity.height) *
                sqElapsed
            )
            context.rotate(by: Angle.degrees(25 * piece.angularVelocity * Double(elapsed)))
            context.fill(
              Self.shape
                .path(in: CGRect(
                  origin: .zero,
                  size: CGSize(
                    width: 5 + (20 * piece.size.width),
                    height: 5 + (20 * piece.size.height)
                  )
                )),
              with: .color(piece.color)
            )
          }
        }
      }
    }
  }
}

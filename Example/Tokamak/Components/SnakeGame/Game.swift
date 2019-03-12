//
//  Game.swift
//  TokamakDemo
//
//  Created by Matvii Hodovaniuk on 2/25/19.
//  Copyright © 2019 Tokamak. Tokamak is available under the Apache 2.0
//  license. See the LICENSE file for more info.
//

import Tokamak

struct Game: Equatable {
  enum State {
    case initial
    case gameOver
    case isPlaying
  }

  var state = State.initial

  enum Direction {
    case up
    case down
    case left
    case right
  }

  var currentDirection = Direction.up

  var snake: [Point] = [
    Point(x: 10.0, y: 10.0),
    Point(x: 10.0, y: 11.0),
    Point(x: 10.0, y: 12.0),
  ]

  var target: Point = Point(x: 0.0, y: 1.0)

  let mapSize: Size

  private func moveHead(_ point: Point) -> Point {
    var x = snake[0].x
    var y = snake[0].y
    switch currentDirection {
    case .left:
      x -= 1
      if x < 0 {
        x = mapSize.width - 1
      }
    case .up:
      y -= 1
      if y < 0 {
        y = mapSize.height - 1
      }
    case .right:
      x += 1
      if x >= mapSize.width {
        x = 0
      }
    case .down:
      y += 1
      if y >= mapSize.height {
        y = 0
      }
    }
    return Point(x: x, y: y)
  }

  public init(mapSize: Size) {
    self.mapSize = mapSize
  }

  public init(state: State, mapSize: Size) {
    self.state = state
    self.mapSize = mapSize
  }
}

extension Game {
  mutating func tick() {
    let head = moveHead(snake[0])
    let isHeadOnTarget = head == target

    if snake.contains(head) {
      state = .gameOver
      return
    }

    snake.insert(head, at: 0)

    if !snake.isEmpty && !isHeadOnTarget {
      snake.removeLast()
    }

    if isHeadOnTarget {
      var newTarget = target

      repeat {
        newTarget = Point(
          x: Double(Int.random(in: 0..<Int(mapSize.width))),
          y: Double(Int.random(in: 0..<Int(mapSize.height)))
        )
      } while snake.contains(newTarget) || newTarget == target

      target = newTarget
    }
  }
}

//
//  Game.swift
//  TokamakDemo
//
//  Created by Matvii Hodovaniuk on 2/25/19.
//  Copyright © 2019 Tokamak. All rights reserved.
//

import Tokamak

struct Game {
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

  var snake: [Point]

  var target: Point

  let mapSize: Size

  var speed: Int = 1

  func canChangeTo(_ newDirection: Direction) -> Bool {
    var canChange = false
    switch currentDirection {
    case .left, .right:
      canChange = newDirection == .up || newDirection == .down
    case Direction.up, Direction.down:
      canChange = newDirection == .left || newDirection == .right
    }
    return canChange
  }

  func move(_ point: Point, mapSize: Size) -> Point {
    var theX = point.x
    var theY = point.y
    switch currentDirection {
    case .left:
      theX -= 1
      if theX <= 0 {
        theX = mapSize.width - 1
      }
    case .up:
      theY -= 1
      if theY <= 0 {
        theY = mapSize.height - 1
      }
    case .right:
      theX += 1
      if theX >= mapSize.width {
        theX = 0
      }
    case .down:
      theY += 1
      if theY >= mapSize.height {
        theY = 0
      }
    }
    return Point(x: theX, y: theY)
  }
}

extension Game {
  mutating func tick() {
    let head = move(snake[0], mapSize: mapSize)
    let isHeadOnTarget = head.x == target.x && head.y == target.y
    snake.insert(head, at: 0)

    if !snake.isEmpty && !isHeadOnTarget {
      snake.removeLast()
    }

    if isHeadOnTarget {
      var isNextTargetGood = false
      var newTarget = target

      while !isNextTargetGood {
        isNextTargetGood = true
        newTarget = Point(
          x: Double(Int.random(in: 0..<Int(mapSize.width))),
          y: Double(Int.random(in: 0..<Int(mapSize.height)))
        )
        if snake.contains(newTarget) || newTarget == target {
          isNextTargetGood = false
        }
      }

      target = newTarget
    }
  }
}

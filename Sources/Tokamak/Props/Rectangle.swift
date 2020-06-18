// Copyright 2018-2020 Tokamak contributors
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
//  Created by Max Desiatov on 29/12/2018.
//

public struct Point: Equatable {
  public let x: Double
  public let y: Double

  public init(x: Double, y: Double) {
    self.x = x
    self.y = y
  }

  public static var zero: Point {
    Point(x: 0, y: 0)
  }
}

public struct Size: Equatable {
  public let width: Double
  public let height: Double

  public init(width: Double, height: Double) {
    self.width = width
    self.height = height
  }

  public static var zero: Size {
    Size(width: 0, height: 0)
  }
}

public struct Rectangle: Equatable {
  public let origin: Point
  public let size: Size

  public init(_ origin: Point, _ size: Size) {
    self.origin = origin
    self.size = size
  }

  public static var zero: Rectangle {
    Rectangle(.zero, .zero)
  }
}

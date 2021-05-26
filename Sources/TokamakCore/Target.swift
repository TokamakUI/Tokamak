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
//  Created by Max Desiatov on 10/02/2019.
//

public protocol RenderingContext: AnyObject {
  func push()
  func pop()
  func translate(x: CGFloat, y: CGFloat)
  var resolvedTransform: CGPoint { get }
}

public protocol BasicRenderingContext: RenderingContext {
  var transformStack: [CGPoint] { get set }
  var current: CGPoint { get set }
}

public extension BasicRenderingContext {
  var resolvedTransform: CGPoint {
    var resolved = CGPoint.zero
    for offset in transformStack + [current] {
      resolved.x += offset.x
      resolved.y += offset.y
    }
    return resolved
  }

  func push() {
    transformStack.append(current)
    current = .zero
  }

  func translate(x: CGFloat, y: CGFloat) {
    current.x += x
    current.y += y
  }

  func pop() {
    current = transformStack.removeLast()
  }
}

public protocol Target: AnyObject {
  var view: AnyView { get set }
  var context: RenderingContext { get }
}

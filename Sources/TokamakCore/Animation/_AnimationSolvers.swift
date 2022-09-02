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
//  Created by Carson Katri on 7/11/21.
//

import Foundation

/// A solver for an animation with a duration that depends on its properties.
public protocol _AnimationSolver {
  /// Solve value at a specific point in time.
  func solve(at t: Double) -> Double
  /// Calculates the duration of the animation to a specific precision.
  func restingPoint(precision y: Double) -> Double
}

public enum _AnimationSolvers {
  // swiftlint:disable line_length
  /// Calculates the animation of a spring with certain properties.
  ///
  /// For some useful information, see
  /// [Demystifying UIKit Spring Animations](https://medium.com/ios-os-x-development/demystifying-uikit-spring-animations-2bb868446773)
  public struct Spring: _AnimationSolver {
    // swiftlint:enable line_length
    let ƛ: Double
    let w0: Double
    let wd: Double
    /// Initial velocity
    let v0: Double
    /// Target value
    let s0: Double = 1

    public init(mass: Double, stiffness: Double, damping: Double, initialVelocity: Double) {
      ƛ = (damping * 0.755) / (mass * 2)
      w0 = sqrt(stiffness / 2)
      wd = sqrt(abs(pow(w0, 2) - pow(ƛ, 2)))
      v0 = initialVelocity
    }

    public func solve(at t: Double) -> Double {
      let y: Double
      if ƛ < w0 {
        y = pow(M_E, -(ƛ * t)) * ((s0 * cos(wd * t)) + ((v0 + s0) * sin(wd * t)))
//      } else if ƛ > w0 { // Overdamping is unsupported on Apple platforms
      } else {
        y = pow(M_E, -(ƛ * t)) * (s0 + ((v0 + (ƛ * s0)) * t))
      }
      return 1 - y
    }

    public func restingPoint(precision y: Double) -> Double {
      log(y) / -ƛ
    }
  }
}

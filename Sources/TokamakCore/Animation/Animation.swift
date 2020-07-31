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

public struct Animation: Equatable {
  static let `default`: Animation

  public func delay(_ delay: Double) -> Animation {
  	.init()
  }

  public func speed(_ speed: Double) -> Animation {
    .init()
  }

  public func repeatCount(
    _ repeatCount: Int, 
    autoreverses: Bool = true
  ) -> Animation {
    .init()
  }
  
  public func repeatForever(autoreverses: Bool = true) -> Animation {
    .init() 
  }
  
  public static func spring(
    response: Double = 0.55, 
    dampingFraction: Double = 0.825, 
    blendDuration: Double = 0
  ) -> Animation {
    .init()
  }

  public static func interactiveSpring(
    response: Double = 0.15, 
    dampingFraction: Double = 0.86, 
    blendDuration: Double = 0.25
  ) -> Animation {
    .init()
  }
  
  public static func interpolatingSpring(
	mass: Double = 1.0, 
	stiffness: Double, 
	damping: Double, 
	initialVelocity: Double = 0.0
  ) -> Animation {
    .init()
  }
  
  public static func easeInOut(duration: Double) -> Animation {
    .init()
  }

  public static var easeInOut: Animation {
    .init()
  }

  public static func easeIn(duration: Double) -> Animation {
    .init()
  }
  
  public static var easeIn: Animation {
    .init()
  }
  public static func easeOut(duration: Double) -> Animation {
    .init()
  }

  public static var easeOut: Animation {
    .init()
  }
  
  public static func linear(duration: Double) -> Animation {
    .init()
  }
  
  public static var linear: Animation {
    .init()
  }
  
  public static func timingCurve(
    _ c0x: Double, 
    _ c0y: Double, 
    _ c1x: Double, 
    _ c1y: Double, 
    duration: Double = 0.35
  ) -> Animation {
    .init()
  }
}
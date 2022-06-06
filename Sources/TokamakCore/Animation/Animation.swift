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

import Foundation

/// This default is specified in SwiftUI on `Animation.timingCurve` as `0.35`.
public let defaultDuration = 0.35

public struct Animation: Equatable {
  fileprivate var box: _AnimationBoxBase

  private init(_ box: _AnimationBoxBase) {
    self.box = box
  }

  public static let `default` = Self.easeInOut

  public func delay(_ delay: Double) -> Animation {
    .init(DelayedAnimationBox(delay: delay, parent: box))
  }

  public func speed(_ speed: Double) -> Animation {
    .init(RetimedAnimationBox(speed: speed, parent: box))
  }

  public func repeatCount(
    _ repeatCount: Int,
    autoreverses: Bool = true
  ) -> Animation {
    .init(RepeatedAnimationBox(style: .fixed(repeatCount, autoreverses: autoreverses), parent: box))
  }

  public func repeatForever(autoreverses: Bool = true) -> Animation {
    .init(RepeatedAnimationBox(style: .forever(autoreverses: autoreverses), parent: box))
  }

  public static func spring(
    response: Double = 0.55,
    dampingFraction: Double = 0.825,
    blendDuration: Double = 0
  ) -> Animation {
    if response == 0 { // Infinitely stiff spring
      // (well, not .infinity, but a very high number)
      return interpolatingSpring(stiffness: 999, damping: 999)
    } else {
      return interpolatingSpring(
        mass: 1,
        stiffness: pow(2 * .pi / response, 2),
        damping: 4 * .pi * dampingFraction / response
      )
    }
  }

  public static func interactiveSpring(
    response: Double = 0.15,
    dampingFraction: Double = 0.86,
    blendDuration: Double = 0.25
  ) -> Animation {
    spring(
      response: response,
      dampingFraction: dampingFraction,
      blendDuration: blendDuration
    )
  }

  public static func interpolatingSpring(
    mass: Double = 1.0,
    stiffness: Double,
    damping: Double,
    initialVelocity: Double = 0.0
  ) -> Animation {
    .init(StyleAnimationBox(style: .solver(_AnimationSolvers.Spring(
      mass: mass,
      stiffness: stiffness,
      damping: damping,
      initialVelocity: initialVelocity
    ))))
  }

  public static func easeInOut(duration: Double) -> Animation {
    timingCurve(0.42, 0, 0.58, 1.0, duration: duration)
  }

  public static var easeInOut: Animation {
    easeInOut(duration: defaultDuration)
  }

  public static func easeIn(duration: Double) -> Animation {
    timingCurve(0.42, 0, 1.0, 1.0, duration: duration)
  }

  public static var easeIn: Animation {
    easeIn(duration: defaultDuration)
  }

  public static func easeOut(duration: Double) -> Animation {
    timingCurve(0, 0, 0.58, 1.0, duration: duration)
  }

  public static var easeOut: Animation {
    easeOut(duration: defaultDuration)
  }

  public static func linear(duration: Double) -> Animation {
    timingCurve(0, 0, 1, 1, duration: duration)
  }

  public static var linear: Animation {
    timingCurve(0, 0, 1, 1)
  }

  public static func timingCurve(
    _ c0x: Double,
    _ c0y: Double,
    _ c1x: Double,
    _ c1y: Double,
    duration: Double = defaultDuration
  ) -> Animation {
    .init(StyleAnimationBox(style: .timingCurve(c0x, c0y, c1x, c1y, duration: duration)))
  }
}

public struct _AnimationProxy {
  let subject: Animation

  public init(_ subject: Animation) { self.subject = subject }

  public func resolve() -> _AnimationBoxBase._Resolved { subject.box.resolve() }
}

@frozen
public struct _AnimationModifier<Value>: ViewModifier, Equatable
  where Value: Equatable
{
  public var animation: Animation?
  public var value: Value

  @inlinable
  public init(animation: Animation?, value: Value) {
    self.animation = animation
    self.value = value
  }

  private struct ContentWrapper: View, Equatable {
    let content: Content
    let animation: Animation?
    let value: Value

    @State
    private var lastValue: Value?

    var body: some View {
      content.transaction {
        if lastValue != value {
          $0.animation = animation
        }
      }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.value == rhs.value
    }
  }

  public func body(content: Content) -> some View {
    ContentWrapper(content: content, animation: animation, value: value)
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.value == rhs.value
      && lhs.animation == rhs.animation
  }
}

@frozen
public struct _AnimationView<Content>: View
  where Content: Equatable, Content: View
{
  public var content: Content
  public var animation: Animation?

  @inlinable
  public init(content: Content, animation: Animation?) {
    self.content = content
    self.animation = animation
  }

  public var body: some View {
    content
      .modifier(_AnimationModifier(animation: animation, value: content))
  }
}

public extension View {
  @inlinable
  func animation<V>(
    _ animation: Animation?,
    value: V
  ) -> some View where V: Equatable {
    modifier(_AnimationModifier(animation: animation, value: value))
  }
}

public extension View where Self: Equatable {
  @inlinable
  func animation(_ animation: Animation?) -> some View {
    _AnimationView(content: self, animation: animation)
  }
}

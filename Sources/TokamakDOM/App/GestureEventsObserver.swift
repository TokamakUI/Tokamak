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
//  Created by Szymon on 23/8/2023.
//

import Foundation
import JavaScriptKit
import OpenCombineShim
import TokamakCore

enum GestureEventsObserver {
  static var publisher = CurrentValueSubject<_GesturePhase?, Never>(nil)

  private static var pointerdown: JSClosure?
  private static var pointermove: JSClosure?
  private static var pointerup: JSClosure?
  private static var pointercancel: JSClosure?

  static func observe(_ rootElement: JSObject) {
    let pointerdown = JSClosure { args -> JSValue in
      if let event = args[0].object,
         let target = event.target.object,
         let x = event.x.jsValue.number,
         let y = event.y.jsValue.number,
         let rect = target.getBoundingClientRect?(),
         let originX = rect.x.number,
         let originY = rect.y.number
      {
        let phase = _GesturePhaseContext(
          eventId: String(describing: target.hashValue),
          boundsOrigin: CGPoint(x: originX, y: originY),
          location: CGPoint(x: x, y: y)
        )
        publisher.send(.began(phase))
      }

      return .undefined
    }

    let pointermove = JSClosure { args -> JSValue in
      if let event = args[0].object,
         let x = event.x.jsValue.number,
         let y = event.y.jsValue.number
      {
        let phase = _GesturePhaseContext(location: CGPoint(x: x, y: y))
        publisher.send(.changed(phase))
      }
      return .undefined
    }

    let pointerup = JSClosure { args -> JSValue in
      if let event = args[0].object,
         let x = event.x.jsValue.number,
         let y = event.y.jsValue.number
      {
        let phase = _GesturePhaseContext(location: CGPoint(x: x, y: y))
        publisher.send(.ended(phase))
      }
      return .undefined
    }

    let pointercancel = JSClosure { _ -> JSValue in
      publisher.send(.cancelled)
      return .undefined
    }

    _ = rootElement.addEventListener?("pointerdown", pointerdown)
    _ = rootElement.addEventListener?("pointermove", pointermove)
    _ = rootElement.addEventListener?("pointerup", pointerup)
    _ = rootElement.addEventListener?("pointercancel", pointercancel)

    Self.pointerdown = pointerdown
    Self.pointermove = pointermove
    Self.pointerup = pointerup
    Self.pointercancel = pointercancel
  }
}

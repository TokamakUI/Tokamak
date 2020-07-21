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
//  Created by Carson Katri on 7/16/20.
//

import JavaScriptKit
import OpenCombine
import TokamakCore

private enum ScenePhaseObserver {
  static var publisher = CurrentValueSubject<ScenePhase, Never>(.active)

  static func observe() {
    let document = JSObjectRef.global.document.object!
    _ = document.addEventListener!("visibilitychange", JSClosure { _ in
      let visibilityState = document.visibilityState.string
      if visibilityState == "visible" {
        publisher.send(.active)
      } else if visibilityState == "hidden" {
        publisher.send(.background)
      }
      return .undefined
    })
  }
}

extension App {
  /// The default implementation of `launch` for a `TokamakDOM` app.
  ///
  /// Creates a host `div` node and appends it to the body.
  ///
  /// The body is styled with `margin: 0;` to match the `SwiftUI` layout
  /// system as closely as possible
  ///
  public static func _launch(_ app: Self,
                             _ rootEnvironment: EnvironmentValues) {
    let document = JSObjectRef.global.document.object!
    let body = document.body.object!
    let head = document.head.object!
    body.style = "margin: 0;"
    let rootStyle = document.createElement!("style").object!
    rootStyle.id = "_tokamak-app-style"
    rootStyle.innerHTML = .string(tokamakStyles)
    _ = head.appendChild!(rootStyle)

    let div = document.createElement!("div").object!
    _ = Unmanaged.passRetained(DOMRenderer(app, div, rootEnvironment))

    _ = body.appendChild!(div)

    ScenePhaseObserver.observe()
  }

  public static func _setTitle(_ title: String) {
    let titleTag = document.createElement!("title").object!
    titleTag.id = "_tokamak-app-title"
    titleTag.innerHTML = .string(title)
    _ = head.appendChild!(titleTag)
  }

  public var _phasePublisher: CurrentValueSubject<ScenePhase, Never> {
    ScenePhaseObserver.publisher
  }
}

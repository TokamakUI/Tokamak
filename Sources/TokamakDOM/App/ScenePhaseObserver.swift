// Copyright 2020-2021 Tokamak contributors
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

import JavaScriptKit
import OpenCombineShim

enum ScenePhaseObserver {
  static var publisher = CurrentValueSubject<ScenePhase, Never>(.active)

  private static var closure: JSClosure?

  static func observe() {
    let closure = JSClosure { _ -> JSValue in
      let visibilityState = document.visibilityState.string
      if visibilityState == "visible" {
        publisher.send(.active)
      } else if visibilityState == "hidden" {
        publisher.send(.background)
      }
      return .undefined
    }
    _ = document.addEventListener!("visibilitychange", closure)
    Self.closure = closure
  }
}

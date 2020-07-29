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

import JavaScriptKit
import TokamakCore

public final class DOMNode: Target {
  let ref: JSObjectRef
  private var listeners: [String: JSClosure]
  public var view: AnyView

  init<V: View>(_ view: V, _ ref: JSObjectRef, _ listeners: [String: Listener] = [:]) {
    self.ref = ref
    self.listeners = [:]
    self.view = AnyView(view)
    reinstall(listeners)
  }

  init(_ ref: JSObjectRef) {
    self.ref = ref
    view = AnyView(EmptyView())
    listeners = [:]
  }

  /// Removes all existing event listeners on this DOM node and install new ones from
  /// the `listeners` argument
  func reinstall(_ listeners: [String: Listener]) {
    for (event, jsClosure) in self.listeners {
      _ = ref.removeEventListener!(event, jsClosure)
    }
    self.listeners = [:]

    for (event, listener) in listeners {
      let jsClosure = JSClosure {
        listener($0[0].object!)
        return .undefined
      }
      _ = ref.addEventListener!(event, jsClosure)
      self.listeners[event] = jsClosure
    }
  }
}

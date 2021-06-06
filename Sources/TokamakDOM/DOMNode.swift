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
import TokamakStaticHTML

extension AnyHTML {
  func update(dom: DOMNode) {
    // FIXME: is there a sensible way to diff attributes and listeners to avoid
    // crossing the JavaScript bridge and touching DOM if not needed?

    // @carson-katri: For diffing, could you build a Set from the keys and values of the dictionary,
    // then use the standard lib to get the difference?

    // `checked` attribute on checkboxes is a special one as its value doesn't matter. We only
    // need to check whether it exists or not, and set the property if it doesn't.
    var containsChecked = false
    for (attribute, value) in attributes {
      if attribute.isUpdatedAsProperty {
        dom.ref[dynamicMember: attribute.value] = .string(value)
      } else {
        _ = dom.ref.setAttribute!(attribute.value, value)
      }

      if attribute == .checked {
        containsChecked = true
      }
    }

    if !containsChecked && dom.ref.type == "checkbox" &&
      dom.ref.tagName.string!.lowercased() == "input"
    {
      dom.ref.checked = .boolean(false)
    }

    if let dynamicSelf = self as? AnyDynamicHTML {
      dom.reinstall(dynamicSelf.listeners)
    }

    guard let innerHTML = innerHTML(shouldSortAttributes: false) else { return }
    dom.ref.innerHTML = .string(innerHTML)
  }
}

final class DOMNode: Target {
  let ref: JSObject
  private var listeners: [String: JSClosure]
  var view: AnyView

  init<V: View>(_ view: V, _ ref: JSObject, _ listeners: [String: Listener] = [:]) {
    self.ref = ref
    self.listeners = [:]
    self.view = AnyView(view)
    reinstall(listeners)
  }

  init(_ ref: JSObject) {
    self.ref = ref
    view = AnyView(EmptyView())
    listeners = [:]
  }

  /// Removes all existing event listeners on this DOM node and install new ones from
  /// the `listeners` argument
  func reinstall(_ listeners: [String: Listener]) {
    for (event, jsClosure) in self.listeners {
      _ = ref.removeEventListener!(event, jsClosure)
      jsClosure.release()
    }
    self.listeners = [:]

    for (event, listener) in listeners {
      let jsClosure = JSClosure {
        listener($0[0].object!)
      }
      _ = ref.addEventListener!(event, jsClosure)
      self.listeners[event] = jsClosure
    }
  }
}

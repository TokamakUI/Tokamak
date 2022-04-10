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

private extension String {
  var animatableProperty: String {
    if self == "float" {
      return "cssFloat"
    } else if self == "offset" {
      return "cssProperty"
    } else {
      return split(separator: "-")
        .reduce("") { prev, next in
          "\(prev)\(prev.isEmpty ? next : next.prefix(1).uppercased() + next.dropFirst())"
        }
    }
  }
}

extension _AnimationBoxBase._Resolved._Style {
  var cssValue: String {
    switch self {
    case let .timingCurve(c0x, c0y, c1x, c1y, _):
      return "cubic-bezier(\(c0x), \(c0y), \(c1x), \(c1y))"
    case .solver:
      return "linear"
    }
  }
}

extension _AnimationBoxBase._Resolved._RepeatStyle {
  var jsValue: JSValue {
    switch self {
    case let .fixed(count, _):
      return count.jsValue
    case .forever:
      return JSObject.global.Infinity
    }
  }
}

extension AnyHTML {
  func update(
    dom: DOMNode,
    computeStart: Bool = true,
    additionalAttributes: [HTMLAttribute: String],
    transaction: Transaction
  ) {
    let attributes = attributes.merging(additionalAttributes, uniquingKeysWith: +)

    dom.applyAttributes(attributes, with: transaction)

    if !transaction.disablesAnimations,
       let animation = transaction.animation,
       let style = attributes["style"]
    {
      dom.animateStyles(to: style, computeStart: computeStart, with: animation)
    }

    if attributes[.checked] == nil && dom.ref.type == "checkbox" &&
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
      #if JAVASCRIPTKIT_WITHOUT_WEAKREFS
      jsClosure.release()
      #endif
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

  func applyAttributes(
    _ attributes: [HTMLAttribute: String],
    with transaction: Transaction
  ) {
    // FIXME: is there a sensible way to diff attributes and listeners to avoid
    // crossing the JavaScript bridge and touching DOM if not needed?

    // @carson-katri: For diffing, could you build a Set from the keys and values of the dictionary,
    // then use the standard lib to get the difference?

    // `checked` attribute on checkboxes is a special one as its value doesn't matter. We only
    // need to check whether it exists or not, and set the property if it doesn't.
    for (attribute, value) in attributes {
      // Animate styles with the Web Animations API in `animateStyles`.
      guard transaction.disablesAnimations
        || transaction.animation == nil
        || attribute != "style"
      else { continue }

      if attribute == "style" { // Clear animations
        ref.getAnimations?().array?.forEach { _ = $0.cancel() }
      }

      if attribute.isUpdatedAsProperty {
        ref[dynamicMember: attribute.value] = .string(value)
      } else {
        _ = ref.setAttribute!(attribute.value, value)
      }
    }
  }

  func extractStyles(compute: Bool = false) -> [String: String] {
    var res = [String: String]()
    let computedStyle = JSObject.global.getComputedStyle?(ref)
    for i in 0..<Int(ref.style.object?.length.number ?? 0) {
      guard let key = ref.style.object?[i].string else { continue }
      if compute {
        res[key] = computedStyle?[dynamicMember: key].string
          ?? ref.style.object?[key].string
      } else {
        res[key] = ref.style.object?[key].string
      }
    }
    return res
  }

  @discardableResult
  func animate(
    keyframes: [JSValue],
    with animation: Animation,
    offsetBy iterationStart: Double = 0
  ) -> JSValue? {
    let resolved = _AnimationProxy(animation).resolve()
    return ref.animate?(
      keyframes,
      [
        "duration": ((resolved.duration / resolved.speed) * 1000).jsValue,
        "delay": (resolved.delay * 1000).jsValue,
        "easing": resolved.style.cssValue.jsValue,
        "iterations": resolved.repeatStyle.jsValue,
        "direction": (resolved.repeatStyle.autoreverses ? "alternate" : "normal").jsValue,
        // Keep the last keyframe applied when done, and the first applied during a delay.
        "fill": "both".jsValue,
        "iterationStart": iterationStart.jsValue,
      ]
    )
  }

  func animateStyles(
    to style: String,
    computeStart: Bool,
    with animation: Animation
  ) {
    let resolved = _AnimationProxy(animation).resolve()

    let startStyle = Dictionary(uniqueKeysWithValues: extractStyles(compute: computeStart).map {
      ($0.animatableProperty, $1)
    }).jsValue
    ref.style.object?.cssText = .string(style)
    let endStyle = Dictionary(uniqueKeysWithValues: extractStyles().map {
      ($0.animatableProperty, $1)
    })

    let keyframes: [JSValue]
    if case let .solver(solver) = resolved.style {
      // Compute styles at several intervals.
      var values = [[String: String]]()
      for iterationStart in stride(from: 0, to: 1, by: 0.01) {
        // Create and immediately cancel an animation after reading the computed values.
        if let animation = animate(
          keyframes: [startStyle, endStyle.jsValue],
          with: Animation.linear(duration: resolved.duration).delay(resolved.delay),
          offsetBy: iterationStart
        )?.object,
          let computedStyle = JSObject.global.getComputedStyle?(ref)
        {
          values.append(Dictionary(
            uniqueKeysWithValues: endStyle.keys
              .compactMap { k in computedStyle[dynamicMember: k].string.map { (k, $0) } }
          ))
          _ = animation.cancel?()
        }
      }
      // Solve the values
      keyframes = (0..<values.count).map { t in
        let offset = Double(t) / Double(values.count - 1)
        let solved = solver.solve(at: offset * (resolved.duration / resolved.speed))
          * Double(values.count - 1)
        var res = values[Int(solved)]
        res["offset"] = "\(offset)"
        return res.jsValue
      } + [endStyle.jsValue] // Add the end for good measure.
    } else {
      keyframes = [startStyle, endStyle.jsValue]
    }
    // Animate the styles.
    animate(keyframes: keyframes, with: animation)
  }
}

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

import Foundation
import JavaScriptKit
@_spi(TokamakCore) import TokamakCore
import TokamakStaticHTML

private let ResizeObserver = JSObject.global.ResizeObserver.function!

extension GeometryReader: DOMPrimitive {
  var renderedBody: AnyView {
    AnyView(_GeometryReader(content: content))
  }
}

struct _GeometryReader<Content: View>: View {
  final class State: ObservableObject {
    /** Holds a strong reference to a `JSClosure` instance that has to stay alive as long as
     the `_GeometryReader` owner is alive.
     */
    var closure: JSClosure?

    /// A reference to a DOM node being observed for size updates.
    var observedNodeRef: JSObject?

    /// A reference to a `ResizeObserver` instance.
    var observerRef: JSObject?

    /// The last known size of the `observedNodeRef` DOM node.
    @Published
    var size: CGSize?
  }

  let content: (GeometryProxy) -> Content

  @StateObject
  private var state = State()

  var body: some View {
    HTML("div", ["class": "_tokamak-geometryreader"]) {
      if let size = state.size {
        content(makeProxy(from: size))
      } else {
        EmptyView()
      }
    }
    ._domRef($state.observedNodeRef)
    ._onMount {
      let closure = JSClosure { [weak state] args -> JSValue in
        // FIXME: `JSArrayRef` is not a `RandomAccessCollection` for some reason, which forces
        // us to use a string subscript
        guard
          let rect = args[0].object?[dynamicMember: "0"].object?.contentRect.object,
          let width = rect.width.number,
          let height = rect.height.number
        else { return .undefined }

        state?.size = .init(width: width, height: height)
        return .undefined
      }
      state.closure = closure

      let observerRef = ResizeObserver.new(closure)

      _ = observerRef.observe!(state.observedNodeRef!)

      state.observerRef = observerRef
    }
  }
}

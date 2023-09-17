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
//  Created by Szymon on 16/7/2023.
//

import TokamakCore

@_spi(TokamakStaticHTML)
import TokamakStaticHTML

extension TokamakCore._GestureView: DOMPrimitive {
  var renderedBody: AnyView {
    AnyView(
      content
        .onReceive(GestureEventsObserver.publisher) { phase in
          guard let phase else { return }
          onPhaseChange(phase)
        }
    )
  }
}

@_spi(TokamakStaticHTML)
extension TokamakCore._GestureView: HTMLConvertible {
  public var tag: String { "div" }
  public var listeners: [String: Listener] { [:] }

  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    [:]
  }

  public func primitiveVisitor<V>(useDynamicLayout: Bool) -> ((V) -> ())? where V: ViewVisitor {
    {
      $0.visit(
        content
          .onReceive(GestureEventsObserver.publisher) { phase in
            guard let phase else { return }
            onPhaseChange(phase)
          }
      )
    }
  }
}

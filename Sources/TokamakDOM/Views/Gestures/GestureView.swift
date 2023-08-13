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

import JavaScriptKit
import TokamakCore
import TokamakStaticHTML
import Foundation

extension TokamakCore._GestureView: DOMPrimitive {
    var renderedBody: AnyView {
        AnyView(
            DynamicHTML("div", ["id": gestureId], listeners: [
                "pointerdown": { event in
                    guard let target = event.target.object,
                          let x = event.x.jsValue.number,
                            let y = event.y.jsValue.number else { return }
                    onPhaseChange(.began(location: CGPoint(x: x, y: y)), eventId: String(describing: target.hashValue))
                },
                "pointermove": { event in
                    guard let x = event.x.jsValue.number, let y = event.y.jsValue.number else { return }
                    let point = CGPoint(x: x, y: y)
                    onPhaseChange(.changed(location: point))
                  },
                "pointerup": { event in
                    guard let x = event.x.jsValue.number, let y = event.y.jsValue.number else { return }
                    onPhaseChange(.ended(location: CGPoint(x: x, y: y)))
                },
                "pointercancel": { event in
                    onPhaseChange(.cancelled)
                }
            ]) {
                content
            }
        )
    }
}

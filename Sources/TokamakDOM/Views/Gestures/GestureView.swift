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
            DynamicHTML("div", [
                "id": gestureId,
                "style": "touch-action: none; user-select: none;"
            ], listeners: [
                "pointerdown": { event in
                    guard let target = event.target.object,
                          let x = event.x.jsValue.number,
                          let y = event.y.jsValue.number,
                          let rect = target.getBoundingClientRect?(),
                          let originX = rect.x.number,
                          let originY = rect.y.number else { return }
                    let phase = _GesturePhaseContext(
                        boundsOrigin: CGPoint(x: originX, y: originY),
                        location: CGPoint(x: x, y: y)
                    )
                    onPhaseChange(.began(phase), eventId: String(describing: target.hashValue))
                },
                "pointercancel": { event in
                    onPhaseChange(.cancelled)
                }
            ]) {
                content
            }.task {
                setupPointerListener()
            }
        )
    }
    
    private func setupPointerListener() {
        /// Global listeners to track continuous pointer movement, providing real-time position updates even outside the initial target bounds.
        let pointermoveClosure = JSClosure { args -> JSValue in
            if let event = args[0].object,
               let x = event.x.jsValue.number,
               let y = event.y.jsValue.number {
                let phase = _GesturePhaseContext(location: CGPoint(x: x, y: y))
                onPhaseChange(.changed(phase))
            }
            return .undefined
        }
        _ = JSObject.global.window.object?.addEventListener?("pointermove", pointermoveClosure)
        
        /// Global listeners to track continuous pointer up, providing real-time updates even outside the initial target bounds.
        let pointerupClosure = JSClosure { args -> JSValue in
            if let event = args[0].object,
               let x = event.x.jsValue.number,
               let y = event.y.jsValue.number {
                let phase = _GesturePhaseContext(location: CGPoint(x: x, y: y))
                onPhaseChange(.ended(phase))
            }
            return .undefined
        }
        _ = JSObject.global.window.object?.addEventListener?("pointerup", pointerupClosure)
    }
}

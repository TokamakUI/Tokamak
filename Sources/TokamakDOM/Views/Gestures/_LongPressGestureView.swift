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
//  Created by Szymon on 30/7/2023.
//

import JavaScriptKit
import TokamakCore
import TokamakStaticHTML
import Foundation

struct _LongPressGestureView<Content: View, G: TokamakCore.Gesture>: View {
    @State var isPressing = false
    @State var location: CGPoint = .zero
    @Binding var gesture: G

    var minimumDuration: Double {
        if let longPressGesture = gesture as? LongPressGesture {
            return longPressGesture.minimumDuration
        }
        return 0.5
    }
    
    let content: Content

    init(gesture: Binding<G>, content: Content) {
        self._gesture = gesture
        self.content = content
    }

    var body: some View {
        DynamicHTML("div", [:], listeners: [
            "pointerdown": { event in
                startDelay()
                isPressing = true
                guard
                  let x = event.x.jsValue.number,
                  let y = event.y.jsValue.number
                else { return }
                let location = CGPoint(x: x, y: y)
                gesture.phase = .began(location: location)
            },
            "pointerup": { _ in
                gesture.phase = .ended(location: .zero)
                isPressing = false
            },
            "pointercancel": { _ in
                gesture.phase = .cancelled
                isPressing = false
            },
            "pointermove": { event in
                guard
                  let x = event.x.jsValue.number,
                  let y = event.y.jsValue.number
                else { return }
                let point = CGPoint(x: x, y: y)
                location = point
                gesture.phase = .changed(location: point)
              },
        ]) {
            content
        }
    }
    
    func startDelay() {
        Task {
            do {
                try await Task.sleep(for: .seconds(minimumDuration))
                if isPressing {
                    await MainActor.run {
                        gesture.phase = .changed(location: location)
                    }
                }
            } catch {
                //TODO: What do we do with this error?
                print(error)
            }
        }
    }
}

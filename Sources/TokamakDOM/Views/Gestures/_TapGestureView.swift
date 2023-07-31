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

struct _TapGestureView<Content: View, G: TokamakCore.Gesture>: View {
    @Binding var gesture: G
    
    let content: Content

    init(gesture: Binding<G>, content: Content) {
        self._gesture = gesture
        self.content = content
    }

    var body: some View {
        DynamicHTML("div", [:], listeners: [
            "pointerdown": { _ in gesture.phase = .began(location: .zero) },
            "pointerup": { _ in gesture.phase = .ended(location: .zero) },
            "pointercancel": { _ in gesture.phase = .cancelled },
        ]) {
            content
        }
    }
}

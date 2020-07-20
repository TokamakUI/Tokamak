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

// import JavaScriptKit
// import TokamakDOM
//
// let document = JSObjectRef.global.document.object!
// let body = document.body.object!
// body.style = "margin: 0;"
//
// let div = document.createElement!("div").object!
// let renderer = DOMRenderer(TokamakDemoView(), div)
//
// _ = body.appendChild!(div)

#if os(WASI)
import TokamakDOM
#else
import SwiftUI
#endif

@available(OSX 10.16, *)
struct TokamakDemoApp: App {
  @Environment(\.scenePhase) private var scenePhase

  var body: some Scene {
    print(scenePhase)
    return WindowGroup("Tokamak Demo") {
      TokamakDemoView()
    }
  }
}

// If @main was supported for executable Swift Packages,
// this would match SwiftUI 100%
if #available(OSX 10.16, *) {
  TokamakDemoApp.main()
}

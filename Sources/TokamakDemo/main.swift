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

import TokamakShim

@available(OSX 10.16, iOS 14.0, *)
struct CustomScene: Scene {
  @Environment(\.scenePhase)
  private var scenePhase

  var body: some Scene {
    print("In CustomScene.body scenePhase is \(scenePhase)")
    return WindowGroup("Tokamak Demo") {
      TokamakDemoView()
    }
  }
}

@available(OSX 10.16, iOS 14.0, *)
struct TokamakDemoApp: App {
  var body: some Scene {
    CustomScene()
  }
}

// If @main was supported for executable Swift Packages,
// this would match SwiftUI 100%
if #available(OSX 10.16, iOS 14.0, *) {
  TokamakDemoApp.main()
}

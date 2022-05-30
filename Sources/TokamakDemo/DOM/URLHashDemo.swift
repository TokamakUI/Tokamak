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

#if os(WASI)
import JavaScriptKit
import TokamakDOM

private let location = JSObject.global.location.object!
private let window = JSObject.global.window.object!

private final class HashState: ObservableObject {
  var onHashChange: JSClosure!

  @Published
  var currentHash = location["hash"].string!

  init() {
    let onHashChange = JSClosure { [weak self] _ in
      self?.currentHash = location["hash"].string!
      return .undefined
    }

    window.onhashchange = .object(onHashChange)
    self.onHashChange = onHashChange
  }

  deinit {
    window.onhashchange = .undefined
    #if JAVASCRIPTKIT_WITHOUT_WEAKREFS
    onHashChange.release()
    #endif
  }
}

struct URLHashDemo: View {
  @StateObject
  private var hashState = HashState()

  var body: some View {
    VStack {
      Button("Assign random location.hash") {
        location["hash"] = .string("\(Int.random(in: 0...1000))")
      }
      Text("Current location.hash is \(hashState.currentHash)")
    }
  }
}
#endif

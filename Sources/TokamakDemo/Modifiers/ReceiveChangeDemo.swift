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
//  Created by Szymon on 24/8/2023.
//

#if os(WASI) && compiler(>=5.5) && (canImport(Concurrency) || canImport(_Concurrency))
import TokamakDOM

struct ReceiveChangeDemo: View {
  @State
  private var count = 0
  @State
  private var count2 = 0

  var body: some View {
    VStack {
      Text("Count: \(count)")
      Text("Count2: \(count2)")

      HStack {
        Button("Increment") {
          count += 1
        }
        Button("Increment2") {
          count2 += 1
        }
      }
    }
    .onChange(of: count) { oldValue, newValue in
      print("🚺 changed \(oldValue) - \(newValue)")
    }
    .onChange(of: count2, initial: true) { oldValue, newValue in
      print("▶️ init, changed \(oldValue) - \(newValue)")
    }
  }
}
#endif

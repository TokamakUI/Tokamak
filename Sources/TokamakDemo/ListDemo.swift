// Copyright 2019-2020 Tokamak contributors
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
//  Created by Carson Katri on 7/2/20.
//

import TokamakShim

public struct ListDemo: View {
  public var body: some View {
    List {
      ForEach(0..<3) {
        Text("Outside Section: \($0 + 1)")
      }
      Section(header: Text("1-10"), footer: Text("End of section")) {
        ForEach(0..<10) {
          Text("Item: \($0 + 1)")
        }
      }
      Section(header: Text("11-20")) {
        ForEach(10..<20) {
          Text("Item: \($0 + 1)")
        }
      }
    }
  }
}

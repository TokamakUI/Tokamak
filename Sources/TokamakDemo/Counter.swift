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
//  Created by Max Desiatov on 14/02/2019.
//

import TokamakDOM

public struct Counter: View {
  @State public var count: Int

  let limit: Int

  public var body: some View {
    count < limit ?
      AnyView(
        VStack {
          Button("Increment") { count += 1 }
          Text("\(count)")
        }
        .onAppear { print("Counter.VStack onAppear") }
        .onDisappear { print("Counter.VStack onDisappear") }
      ) : AnyView(
        VStack { Text("Limit exceeded") }
      )
  }
}

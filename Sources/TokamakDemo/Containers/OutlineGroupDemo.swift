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
//  Created by Carson Katri on 7/3/20.
//

import TokamakShim

struct File: Identifiable {
  let id: Int
  let name: String
  let children: [File]?
}

struct OutlineGroupDemo: View {
  let fs: [File] = [
    .init(id: 0, name: "Users", children: [
      .init(id: 1, name: "carson", children: [
        .init(id: 2, name: "home", children: [
          .init(id: 3, name: "Documents", children: nil),
          .init(id: 4, name: "Desktop", children: nil),
        ]),
      ]),
    ]),
  ]

  var body: some View {
    OutlineGroup(fs, children: \.children) { folder in
      HStack {
        Text(folder.children == nil ? "" : "🗂")
        Text(folder.name)
      }
    }
  }
}

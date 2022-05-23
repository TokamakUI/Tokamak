// Copyright 2022 Tokamak contributors
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
//  Created by Andrew Barba on 5/20/22.
//

import TokamakCore

public struct HTMLTitle: View {
  var title: String

  public init(_ title: String) {
    self.title = title
  }

  public var body: some View {
    EmptyView()
      .preference(key: HTMLTitlePreferenceKey.self, value: title)
  }
}

public extension View {
  func htmlTitle(_ title: String) -> some View {
    htmlTitle(.init(title))
  }

  func htmlTitle(_ title: HTMLTitle) -> some View {
    Group {
      self
      title
    }
  }
}

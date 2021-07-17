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
//  Created by Carson Katri on 1/19/21.
//

public struct NavigationBarItem: Equatable {
  let displayMode: TitleDisplayMode

  public enum TitleDisplayMode: Hashable {
    case automatic
    case inline
    case large
  }
}

public struct _NavigationBarItemProxy {
  let subject: NavigationBarItem

  public init(_ subject: NavigationBarItem) {
    self.subject = subject
  }

  public var displayMode: NavigationBarItem.TitleDisplayMode {
    subject.displayMode
  }
}

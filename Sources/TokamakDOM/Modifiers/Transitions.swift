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
//  Created by Carson Katri on 7/13/21.
//

import TokamakCore
import TokamakStaticHTML

extension _MoveTransition: DOMViewModifier {
  public var attributes: [HTMLAttribute: String] {
    let offset: (String, String)
    switch edge {
    case .leading: offset = ("-100%", "0%")
    case .trailing: offset = ("100%", "0%")
    case .top: offset = ("0%", "-100%")
    case .bottom: offset = ("0%", "100%")
    }
    return [
      "style":
        "transform: translate(\(isActive ? offset.0 : "0%"), \(isActive ? offset.1 : "0%"));",
    ]
  }
}

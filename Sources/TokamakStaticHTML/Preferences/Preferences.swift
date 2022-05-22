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

struct HTMLTitlePreferenceKey: PreferenceKey {
    static var defaultValue: String = ""

    static func reduce(value: inout String, nextValue: () -> String) {
        value = nextValue()
    }
}

struct HTMLMetaPreferenceKey: PreferenceKey {
    internal enum HTMLMeta: Equatable, Hashable {
        case charset(_ charset: String)
        case name(_ name: String, content: String)
        case property(_ property: String, content: String)
        case httpEquiv(_ httpEquiv: String, content: String)
    }

    static var defaultValue: [HTMLMeta] = []

    static func reduce(value: inout [HTMLMeta], nextValue: () -> [HTMLMeta]) {
        value.append(contentsOf: nextValue())
    }
}

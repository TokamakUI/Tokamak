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
//  Created by Carson Katri on 6/20/22.
//

#if os(macOS)
import SwiftUI
import TokamakStaticHTML

extension SwiftUI.HorizontalAlignment {
  static var allCases: [(SwiftUI.HorizontalAlignment, TokamakStaticHTML.HorizontalAlignment)] {
    [(.leading, .leading), (.center, .center), (.trailing, .trailing)]
  }
}

extension SwiftUI.VerticalAlignment {
  static var allCases: [(SwiftUI.VerticalAlignment, TokamakStaticHTML.VerticalAlignment)] {
    [(.top, .top), (.center, .center), (.bottom, .bottom)]
  }
}
#endif

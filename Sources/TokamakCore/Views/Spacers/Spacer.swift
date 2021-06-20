// Copyright 2020-2021 Tokamak contributors
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
//  Created by Carson Katri on 06/29/2020.
//

import Foundation

/// A `View` that fills the major axis of its parent stack.
///
///     HStack {
///       Text("Hello")
///       Spacer()
///       Text("World")
///     }
public struct Spacer: _PrimitiveView {
  public var minLength: CGFloat?

  public init(minLength: CGFloat? = nil) {
    self.minLength = minLength
  }
}

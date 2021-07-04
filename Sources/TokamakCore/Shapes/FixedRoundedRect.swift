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
//  Created by Carson Katri on 7/22/20.
//

import Foundation

public struct FixedRoundedRect: Equatable {
  public let rect: CGRect
  public let cornerSize: CGSize?
  public let style: RoundedCornerStyle

  public init(rect: CGRect, cornerSize: CGSize, style: RoundedCornerStyle) {
    (self.rect, self.cornerSize, self.style) = (rect, cornerSize, style)
  }

  init(capsule rect: CGRect, style: RoundedCornerStyle) {
    (self.rect, cornerSize, self.style) = (rect, nil, style)
  }
}

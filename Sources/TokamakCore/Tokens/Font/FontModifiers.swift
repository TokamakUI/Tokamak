// Copyright 2018-2021 Tokamak contributors
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

import Foundation

public extension Font {
  func italic() -> Self {
    .init(_ModifiedFontBox(previously: provider) {
      $0._italic = true
    })
  }

  func smallCaps() -> Self {
    .init(_ModifiedFontBox(previously: provider) {
      $0._smallCaps = true
    })
  }

  func lowercaseSmallCaps() -> Self {
    smallCaps()
  }

  func uppercaseSmallCaps() -> Self {
    smallCaps()
  }

  func monospacedDigit() -> Self {
    .init(_ModifiedFontBox(previously: provider) {
      $0._monospaceDigit = true
    })
  }

  func weight(_ weight: Weight) -> Self {
    .init(_ModifiedFontBox(previously: provider) {
      $0._weight = weight
    })
  }

  func bold() -> Self {
    .init(_ModifiedFontBox(previously: provider) {
      $0._bold = true
    })
  }

  func leading(_ leading: Leading) -> Self {
    .init(_ModifiedFontBox(previously: provider) {
      $0._leading = leading
    })
  }
}

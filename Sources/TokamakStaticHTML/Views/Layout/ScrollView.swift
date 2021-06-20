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
//  Created by Carson Katri on 06/29/2020.
//

import TokamakCore

extension ScrollView: _HTMLPrimitive, SpacerContainer {
  public var axis: SpacerContainerAxis {
    if axes.contains(.horizontal) {
      return .horizontal
    } else {
      return .vertical
    }
  }

  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    let scrollX = axes.contains(.horizontal)
    let scrollY = axes.contains(.vertical)
    return AnyView(HTML("div", [
      "style": """
      \(scrollX ? "overflow-x: auto; width: 100%;" : "overflow-x: hidden;")
      \(scrollY ? "overflow-y: auto; height: 100%;" : "overflow-y: hidden;")
      \(fillCrossAxis && scrollX ? "height: 100%;" : "")
      \(fillCrossAxis && scrollY ? "width: 100%;" : "")
      """,
      "class": !showsIndicators ? "_tokamak-scrollview _tokamak-scrollview-hideindicators" :
        "_tokamak-scrollview",
    ]) {
      VStack {
        content
      }
    })
  }
}

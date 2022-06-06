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
//  Created by Carson Katri on 2/15/22.
//

import Foundation

public enum Mutation<Renderer: FiberRenderer> {
  case insert(
    element: Renderer.ElementType,
    parent: Renderer.ElementType,
    index: Int
  )
  case remove(element: Renderer.ElementType, parent: Renderer.ElementType?)
  case replace(
    parent: Renderer.ElementType,
    previous: Renderer.ElementType,
    replacement: Renderer.ElementType
  )
  case update(
    previous: Renderer.ElementType,
    newContent: Renderer.ElementType.Content,
    geometry: ViewGeometry
  )
  case layout(element: Renderer.ElementType, geometry: ViewGeometry)
}

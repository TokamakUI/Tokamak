// Copyright 2018-2020 Tokamak contributors
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
//  Created by Carson Katri on 7/19/20.
//

import OpenCombine

class MountedCompositeElement<R: Renderer>: MountedElement<R>, Hashable {
  static func == (lhs: MountedCompositeElement<R>,
                  rhs: MountedCompositeElement<R>) -> Bool {
    lhs === rhs
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }

  var mountedChildren = [MountedElement<R>]()
  let parentTarget: R.TargetType

  var state = [StateLocation]()
  var subscriptions = [AnyCancellable]()
  var environmentValues: EnvironmentValues

  init(_ app: _AnyApp,
       _ parentTarget: R.TargetType,
       _ environmentValues: EnvironmentValues) {
    self.parentTarget = parentTarget
    self.environmentValues = environmentValues
    super.init(app)
  }

  init(_ view: AnyView,
       _ parentTarget: R.TargetType,
       _ environmentValues: EnvironmentValues) {
    self.parentTarget = parentTarget
    self.environmentValues = environmentValues
    super.init(view)
  }
}

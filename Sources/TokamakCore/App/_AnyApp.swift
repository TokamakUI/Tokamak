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
//  Created by Carson Katri on 7/19/20.
//

import OpenCombine

public struct _AnyApp: App {
  var app: Any
  let appType: Any.Type
  let bodyClosure: (Any) -> _AnyScene
  let bodyType: Any.Type

  init<A: App>(_ app: A) {
    self.app = app
    appType = A.self
    // swiftlint:disable:next force_cast
    bodyClosure = { _AnyScene(($0 as! A).body) }
    bodyType = A.Body.self
  }

  public var body: Never {
    neverScene("_AnyApp")
  }

  public init() {
    fatalError("`_AnyApp` cannot be initialized without an underlying `App` type.")
  }

  public static func _launch(_ app: Self,
                             _ rootEnvironment: EnvironmentValues) {
    fatalError("`_AnyApp` cannot be launched. Access underlying `app` value.")
  }

  public static func _setTitle(_ title: String) {
    fatalError("`title` cannot be set for `AnyApp`. Access underlying `app` value.")
  }

  public var _phasePublisher: CurrentValueSubject<ScenePhase, Never> {
    fatalError("`_AnyApp` cannot monitor scenePhase. Access underlying `app` value.")
  }

  public var _colorSchemePublisher: CurrentValueSubject<ColorScheme, Never> {
    fatalError("`_AnyApp` cannot monitor scenePhase. Access underlying `app` value.")
  }
}

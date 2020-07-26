// Copyright 2019-2020 Tokamak contributors
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
//  Created by Max Desiatov on 10/02/2019.
//

open class Target {
  var element: MountedElementKind
  public internal(set) var app: _AnyApp {
    get {
      if case let .app(app) = element {
        return app
      } else {
        fatalError("`Target` has type \(element) not `App`")
      }
    }
    set {
      element = .app(newValue)
    }
  }

  public internal(set) var scene: _AnyScene {
    get {
      if case let .scene(scene) = element {
        return scene
      } else {
        fatalError("`Target` has type \(element) not `Scene`")
      }
    }
    set {
      element = .scene(newValue)
    }
  }

  public internal(set) var view: AnyView {
    get {
      if case let .view(view) = element {
        return view
      } else {
        fatalError("`Target` has type \(element) not `View`")
      }
    }
    set {
      element = .view(newValue)
    }
  }

  public init<V: View>(_ view: V) {
    element = .view(AnyView(view))
  }

  public init<A: App>(_ app: A) {
    element = .app(_AnyApp(app))
  }
}

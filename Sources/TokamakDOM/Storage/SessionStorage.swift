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
//  Created by Carson Katri on 7/20/20.
//

import JavaScriptKit
import OpenCombine
import TokamakCore

public class SessionStorage: _SceneStorageProvider {
  let sessionStorage = JSObjectRef.global.sessionStorage.object!

  init() {
    subscription = Self.rootPublisher.sink { _ in
      self.publisher.send()
    }
  }

  public func store(key: String, value: String) {
    Self.rootPublisher.send()
    _ = sessionStorage.setItem!(key, value)
  }

  public func read(key: String) -> String? {
    sessionStorage.getItem!(key).string
  }

  public static var standard: _SceneStorageProvider {
    SessionStorage()
  }

  var subscription: AnyCancellable?
  static let rootPublisher = ObservableObjectPublisher()
  public let publisher = ObservableObjectPublisher()
}
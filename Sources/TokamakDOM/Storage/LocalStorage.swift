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
//  Created by Carson Katri on 7/20/20.
//

import JavaScriptKit
import OpenCombineShim
import TokamakCore

private let rootPublisher = ObservableObjectPublisher()
private let localStorage = JSObject.global.localStorage.object!

public class LocalStorage: WebStorage, _StorageProvider {
  static let closure = JSClosure { _ in
    rootPublisher.send()
    return .undefined
  }

  let storage = localStorage

  required init() {
    _ = JSObject.global.window.object!.addEventListener!("storage", Self.closure)
    publisher = rootPublisher
  }

  public static var standard: _StorageProvider {
    Self()
  }

  public let publisher: ObservableObjectPublisher
}

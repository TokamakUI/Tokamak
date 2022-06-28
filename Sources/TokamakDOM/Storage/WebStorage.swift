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
//  Created by Carson Katri on 7/21/20.
//

import JavaScriptKit
import OpenCombineShim
import TokamakCore

protocol WebStorage {
  var storage: JSObject { get }
  init()

  func setItem<Value>(key: String, value: Value?)
  func getItem<Value>(key: String, _ initialize: (String) -> Value?) -> Value?

  var publisher: ObservableObjectPublisher { get }
}

extension WebStorage {
  func setItem<Value>(key: String, value: Value?) {
    publisher.send()
    if let value = value {
      _ = storage.setItem!(key, String(describing: value))
    }
  }

  func getItem<Value>(key: String, _ initialize: (String) -> Value?) -> Value? {
    guard let value = storage.getItem!(key).string else {
      return nil
    }
    return initialize(value)
  }

  public func store(key: String, value: Bool?) {
    setItem(key: key, value: value)
  }

  public func store(key: String, value: Int?) {
    setItem(key: key, value: value)
  }

  public func store(key: String, value: Double?) {
    setItem(key: key, value: value)
  }

  public func store(key: String, value: String?) {
    setItem(key: key, value: value)
  }

  public func read(key: String) -> Bool? {
    getItem(key: key, Bool.init)
  }

  public func read(key: String) -> Int? {
    getItem(key: key, Int.init)
  }

  public func read(key: String) -> Double? {
    getItem(key: key, Double.init)
  }

  public func read(key: String) -> String? {
    getItem(key: key) { $0 }
  }
}

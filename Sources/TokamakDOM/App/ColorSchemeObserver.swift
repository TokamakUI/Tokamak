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

import JavaScriptKit
import OpenCombineShim

enum ColorSchemeObserver {
  static var publisher = CurrentValueSubject<ColorScheme, Never>(
    .init(matchMediaDarkScheme: matchMediaDarkScheme)
  )

  private static var closure: JSClosure?
  private static var cancellable: AnyCancellable?

  static func observe(_ rootElement: JSObject) {
    let closure = JSClosure {
      publisher.value = .init(matchMediaDarkScheme: $0[0].object!)
      return .undefined
    }
    _ = matchMediaDarkScheme.addListener!(closure)
    Self.closure = closure
    Self.cancellable = Self.publisher.sink { colorScheme in
      let systemBackground: String
      switch colorScheme {
      case .light: systemBackground = "#FFFFFF"
      case .dark: systemBackground = "rgb(38, 38, 38)"
      }
      rootElement.style.object!.backgroundColor = .string("\(systemBackground)")
    }
  }
}

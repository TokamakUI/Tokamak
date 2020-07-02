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

import JavaScriptKit
import TokamakCore

/// This is effectively a singleton, but a mounted `DOMEnvironment` is assumed to be a singleton
/// too. It can't be declared as a property of `DOMEnvironment` as you can't modify it from within
/// `body` callbacks.
private var colorSchemeListener: JSClosure?

struct DOMEnvironment<V: View>: View {
  @State var scheme: ColorScheme

  let content: V

  private let matchMedia =
    JSObjectRef.global.window.object!.matchMedia!("(prefers-color-scheme: dark)").object!

  var body: some View {
    content
      .colorScheme(scheme)
      .onAppear {
        colorSchemeListener = JSClosure {
          scheme = $0[0].object!.matches.boolean == true ? .dark : .light
          return .undefined
        }
        _ = matchMedia.addEventListener!("change", colorSchemeListener!)
      }.onDisappear {
        _ = matchMedia.removeEventListener!("change", colorSchemeListener!)
      }
  }
}

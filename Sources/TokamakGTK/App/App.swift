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
//  Created by Carson Katri on 10/10/20.
//

import CGTK
import Dispatch
import OpenCombineShim
import TokamakCore

public extension App {
  static func _launch(_ app: Self, with configuration: _AppConfiguration) {
    _ = Unmanaged.passRetained(GTKRenderer(app, configuration.rootEnvironment))
  }

  static func _setTitle(_ title: String) {
    GTKRenderer.sharedWindow.withMemoryRebound(to: GtkWindow.self, capacity: 1) {
      gtk_window_set_title($0, title)
    }
  }

  var _phasePublisher: AnyPublisher<ScenePhase, Never> {
    CurrentValueSubject(.active).eraseToAnyPublisher()
  }

  var _colorSchemePublisher: AnyPublisher<ColorScheme, Never> {
    CurrentValueSubject(.light).eraseToAnyPublisher()
  }
}

extension UnsafeMutablePointer where Pointee == GApplication {
  @discardableResult
  func connect(
    signal: UnsafePointer<gchar>,
    data: UnsafeMutableRawPointer? = nil,
    handler: @convention(c) @escaping (UnsafeMutablePointer<GtkApplication>?, UnsafeRawPointer)
      -> Bool
  ) -> Int {
    let handler = unsafeBitCast(handler, to: GCallback.self)
    return Int(g_signal_connect_data(self, signal, handler, data, nil, GConnectFlags(rawValue: 0)))
  }

  /// Connect with a context-capturing closure.
  @discardableResult
  func connect(
    signal: UnsafePointer<gchar>,
    closure: @escaping () -> ()
  ) -> Int {
    let closureBox = Unmanaged.passRetained(ClosureBox(closure)).toOpaque()
    return connect(signal: signal, data: closureBox) { _, closureBox in
      let unpackedAction = Unmanaged<ClosureBox<()>>.fromOpaque(closureBox)
      unpackedAction.takeRetainedValue().closure()
      return true
    }
  }
}

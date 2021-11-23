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
//  Created by Carson Katri on 10/10/2020.
//

import CGTK

extension UnsafeMutablePointer where Pointee == GtkWidget {
  /// Connect with a c function pointer.
  @discardableResult
  func connect(
    signal: UnsafePointer<gchar>,
    data: gpointer? = nil,
    handler: @convention(c) @escaping (UnsafeMutablePointer<GtkWidget>?, UnsafeRawPointer) -> Bool,
    destroy: @convention(c) @escaping (UnsafeRawPointer, UnsafeRawPointer) -> ()
  ) -> Int {
    let handler = unsafeBitCast(handler, to: GCallback.self)
    let destroy = unsafeBitCast(destroy, to: GClosureNotify.self)
    return Int(g_signal_connect_data(
      self,
      signal,
      handler,
      data,
      destroy,
      GConnectFlags(rawValue: 0)
    ))
  }

  /// Connect with a c function pointer, but with an extra opaque pointer.
  @discardableResult
  func connect(
    signal: UnsafePointer<gchar>,
    data: gpointer? = nil,
    handler: @convention(c) @escaping (
      UnsafeMutablePointer<GtkWidget>?,
      OpaquePointer,
      UnsafeRawPointer
    ) -> Bool,
    destroy: @convention(c) @escaping (UnsafeRawPointer, UnsafeRawPointer) -> ()
  ) -> Int {
    let handler = unsafeBitCast(handler, to: GCallback.self)
    let destroy = unsafeBitCast(destroy, to: GClosureNotify.self)
    return Int(g_signal_connect_data(
      self,
      signal,
      handler,
      data,
      destroy,
      GConnectFlags(rawValue: 0)
    ))
  }

  /// Connect with a context-capturing closure.
  @discardableResult
  func connect(
    signal: UnsafePointer<gchar>,
    closure: @escaping () -> ()
  ) -> Int {
    let closureBox = Unmanaged.passRetained(ClosureBox(closure)).toOpaque()
    return connect(signal: signal, data: closureBox, handler: { _, closureBox in
      let unpackedAction = Unmanaged<ClosureBox<()>>.fromOpaque(closureBox)
      unpackedAction.takeUnretainedValue().closure()
      return true
    }, destroy: { closureBox, _ in
      let unpackedAction = Unmanaged<ClosureBox<()>>.fromOpaque(closureBox)
      unpackedAction.release()
    })
  }

  /// Connect with a context-capturing closure (with the GtkWidget passed through)
  @discardableResult
  func connect(
    signal: UnsafePointer<gchar>,
    closure: @escaping (UnsafeMutablePointer<GtkWidget>?) -> ()
  ) -> Int {
    let closureBox = Unmanaged.passRetained(SingleParamClosureBox(closure)).retain().toOpaque()
    return connect(signal: signal, data: closureBox, handler: { widget, closureBox in
      let unpackedAction = Unmanaged<SingleParamClosureBox<UnsafeMutablePointer<GtkWidget>?, ()>>
        .fromOpaque(closureBox)
      if let widget = widget {
        unpackedAction.takeUnretainedValue().closure(widget)
      }
      return true
    }, destroy: { closureBox, _ in
      let unpackedAction = Unmanaged<SingleParamClosureBox<UnsafeMutablePointer<GtkWidget>?, ()>>
        .fromOpaque(closureBox)
      unpackedAction.release()
    })
  }

  /// Connect with a context-capturing closure (with the GtkWidget and an
  /// OpaquePointer passed through)
  @discardableResult
  func connect(
    signal: UnsafePointer<gchar>,
    closure: @escaping (UnsafeMutablePointer<GtkWidget>?, OpaquePointer) -> ()
  ) -> Int {
    let closureBox = Unmanaged.passRetained(DualParamClosureBox(closure)).retain().toOpaque()
    return connect(signal: signal, data: closureBox, handler: { widget, context, closureBox in
      let unpackedAction = Unmanaged<DualParamClosureBox<
        UnsafeMutablePointer<GtkWidget>?,
        OpaquePointer,
        ()
      >>
      .fromOpaque(closureBox)
      if let widget = widget {
        unpackedAction.takeUnretainedValue().closure(widget, context)
      }
      return true
    }, destroy: { closureBox, _ in
      let unpackedAction = Unmanaged<DualParamClosureBox<
        UnsafeMutablePointer<GtkWidget>?,
        OpaquePointer,
        ()
      >>
      .fromOpaque(closureBox)
      unpackedAction.release()
    })
  }

  func disconnect(
    gtype: GType,
    signal: UnsafePointer<gchar>
  ) {
    // Find the signal ID from the signal `gchar` for the specified `GtkWidget` type.
    let sigId = g_signal_lookup(signal, gtype)
    // Get the bound handler ID from the instance.
    let handlerId = g_signal_handler_find(self, G_SIGNAL_MATCH_ID, sigId, 0, nil, nil, nil)
    // Disconnect the handler from the instance.
    g_signal_handler_disconnect(self, handlerId)
  }
}

final class ClosureBox<U> {
  let closure: () -> U

  init(_ closure: @escaping () -> U) { self.closure = closure }
}

final class SingleParamClosureBox<T, U> {
  let closure: (T) -> U

  init(_ closure: @escaping (T) -> U) { self.closure = closure }
}

final class DualParamClosureBox<T, U, V> {
  let closure: (T, U) -> V

  init(_ closure: @escaping (T, U) -> V) { self.closure = closure }
}

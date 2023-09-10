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
//  Created by Szymon on 20/8/2023.
//

import Foundation
import OpenCombineShim

private struct OnReceiveModifier<P: Publisher>: ViewModifier where P.Failure == Never {
  @ObservedObject
  var cancellableHolder = CancellableHolder()

  init(publisher: P, action: @escaping (P.Output) -> ()) {
    cancellableHolder.cancellable = publisher.sink(receiveValue: action)
  }

  func body(content: Content) -> some View {
    content
  }

  // MARK: Types

  final class CancellableHolder: ObservableObject {
    var cancellable: AnyCancellable? {
      didSet {
        oldValue?.cancel()
      }
    }

    deinit {
      cancellable?.cancel()
    }
  }
}

public extension View {
  /// Adds an action to perform when this view detects data emitted by the given publisher.
  /// - Parameters:
  ///   - publisher: The publisher to subscribe to.
  ///   - action: The action to perform when an event is emitted by publisher. The event emitted by
  /// publisher is passed as a parameter to action.
  /// - Returns: A view that triggers action when publisher emits an event.
  func onReceive<P>(
    _ publisher: P,
    perform action: @escaping (P.Output) -> ()
  ) -> some View where P: Publisher, P.Failure == Never {
    modifier(OnReceiveModifier(publisher: publisher, action: action))
  }
}

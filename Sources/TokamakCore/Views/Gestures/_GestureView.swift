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
//  Created by Szymon on 16/7/2023.
//

import Foundation

public struct _GestureView<Content: View, G: Gesture>: _PrimitiveView {
  final class Coordinator<G: Gesture>: ObservableObject {
    var gesture: G
    var gestureId: String = UUID().uuidString
    var eventId: String? = nil

    init(_ gesture: G) {
      self.gesture = gesture
    }
  }

  @Environment(\.isEnabled)
  var isEnabled
  @Environment(\._gestureListener)
  var gestureListener
  @StateObject
  private var coordinator: Coordinator<G>

  let mask: GestureMask
  let priority: _GesturePriority
  public let content: Content
  public var gestureId: String {
    coordinator.gestureId
  }

  var minimumDuration: Double? {
    guard let longPressGesture = coordinator.gesture as? LongPressGesture else {
      return nil
    }
    return longPressGesture.minimumDuration
  }

  public init(
    gesture: G,
    mask: GestureMask,
    priority: _GesturePriority = .standard,
    content: Content
  ) {
    _coordinator = StateObject(wrappedValue: Coordinator(gesture))
    self.mask = mask
    self.priority = priority
    self.content = content
  }

  public func onPhaseChange(_ phase: _GesturePhase) {
    guard isEnabled else {
      // View needs to be enabled in order for the gestures to work
      return
    }

    let value = GestureValue(
      gestureId: gestureId,
      mask: mask,
      priority: priority
    )

    var eventId = coordinator.eventId

    switch phase {
    case let .began(context) where context.eventId != nil:
      startDelay()
      coordinator.eventId = context.eventId
      gestureListener.registerStart(value, for: context.eventId!)
      eventId = context.eventId
    case .cancelled, .ended:
      coordinator.eventId = nil
    default:
      break
    }

    guard let currentEventId = eventId else {
      // Gesture has not started
      return
    }
    guard gestureListener.canProcessGesture(value, for: currentEventId) else {
      // Event being processed by another gestures
      return
    }

    if coordinator.gesture._onPhaseChange(phase) {
      gestureListener.recognizeGesture(value, for: currentEventId)
    }
  }

  private func startDelay() {
    guard let minimumDuration else { return }
    Task {
      do {
        try await Task.sleep(for: .seconds(minimumDuration))
        if let eventId = coordinator.eventId {
          await MainActor.run {
            onPhaseChange(.changed(_GesturePhaseContext(eventId: eventId)))
          }
        }
      } catch {}
    }
  }
}

// MARK: View Extension

public extension View {
  /// Attaches a single gesture to the view.
  ///
  /// - Parameter gesture: The gesture to attach.
  /// - Returns: A modified version of the view with the gesture attached.
  @ViewBuilder
  func gesture<T>(_ gesture: T?, including mask: GestureMask = .all) -> some View
    where T: Gesture
  {
    if let gesture {
      _GestureView(gesture: gesture.body, mask: mask, content: self)
    } else {
      self
    }
  }

  /// Attaches a gesture to the view to process simultaneously with gestures defined by the view.
  /// - Parameter gesture: The gesture to attach.
  /// - Returns: A modified version of the view with the gesture attached.
  @ViewBuilder
  func simultaneousGesture<T>(_ gesture: T?, including mask: GestureMask = .all) -> some View
    where T: Gesture
  {
    if let gesture {
      _GestureView(
        gesture: gesture.body,
        mask: mask,
        priority: .simultaneous,
        content: self
      )
    } else {
      self
    }
  }

  /// Attaches a gesture to the view with a higher precedence than gestures defined by the view.
  /// - Parameters:
  ///   - gesture: A gesture to attach to the view.
  ///   - mask: A value that controls how adding this gesture to the view affects other gestures
  /// recognized by the view and its subviews. Defaults to all.
  /// - Returns: A modified version of the view with the gesture attached.
  @ViewBuilder
  func highPriorityGesture<T>(_ gesture: T?, including mask: GestureMask = .all) -> some View
    where T: Gesture
  {
    if let gesture {
      _GestureView(
        gesture: gesture.body,
        mask: mask,
        priority: .highPriority,
        content: self
      )
    } else {
      self
    }
  }
}

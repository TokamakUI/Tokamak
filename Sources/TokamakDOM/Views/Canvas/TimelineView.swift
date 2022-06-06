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
//  Created by Carson Katri on 9/18/21.
//

import Foundation
import JavaScriptKit
import TokamakCore

extension EnvironmentValues {
  private enum InAnimatingTimelineViewKey: EnvironmentKey {
    static let defaultValue: Bool = false
  }

  var inAnimatingTimelineView: Bool {
    get { self[InAnimatingTimelineViewKey.self] }
    set { self[InAnimatingTimelineViewKey.self] = newValue }
  }

  private enum IsAnimatingTimelineViewPausedKey: EnvironmentKey {
    static let defaultValue: Bool = false
  }

  var isAnimatingTimelineViewPaused: Bool {
    get { self[IsAnimatingTimelineViewPausedKey.self] }
    set { self[IsAnimatingTimelineViewPausedKey.self] = newValue }
  }
}

private struct _TimelineView<Content: View, Schedule: TimelineSchedule>: View {
  let parent: _TimelineViewProxy<Schedule, Content>

  @StateObject
  private var coordinator: Coordinator

  @Environment(\.inAnimatingTimelineView)
  private var inAnimatingTimelineView

  @Environment(\.isAnimatingTimelineViewPaused)
  private var isAnimatingTimelineViewPaused

  init(parent: TimelineView<Schedule, Content>) {
    self.parent = _TimelineViewProxy(parent)
    _coordinator = .init(
      wrappedValue: Coordinator(
        entries: _TimelineViewProxy(parent).schedule
          .entries(from: Date(), mode: .lowFrequency)
      )
    )
  }

  final class Coordinator: ObservableObject {
    @Published
    var date = Date()
    var iterator: Schedule.Entries.Iterator
    var timeoutID: JSValue?

    init(entries: Schedule.Entries) {
      iterator = entries.makeIterator()
      queueNext()
    }

    func queueNext() {
      // Animated timelines are handled differently on the web, as updating the DOM every frame
      // is costly. Therefore, animated timelines are only supported by views that read the
      // `inAnimatingTimelineView` environment value, such as `Canvas`, which updates without
      // DOM manipulation.
      guard !(Schedule.self == AnimationTimelineSchedule.self),
            let next = iterator.next()
      else { return }
      timeoutID = JSObject.global.setTimeout!(
        JSOneshotClosure { [weak self] _ in
          self?.date = next
          self?.queueNext()
          return .undefined
        },
        date.distance(to: next) * 1000
      )
    }

    deinit {
      guard let timeoutID = timeoutID else { return }
      _ = JSObject.global.clearTimeout!(timeoutID)
    }
  }

  var body: some View {
    parent.content(
      parent.context(
        date: {
          if parent.schedule is AnimationTimelineSchedule {
            return Date()
          } else {
            return coordinator.date
          }
        }
      )
    )
    .environment(
      \.inAnimatingTimelineView,
      inAnimatingTimelineView || (parent.schedule is AnimationTimelineSchedule)
    )
    .environment(
      \.isAnimatingTimelineViewPaused,
      ((parent.schedule as? AnimationTimelineSchedule)?._paused ?? false) &&
        (!inAnimatingTimelineView || isAnimatingTimelineViewPaused)
    )
  }
}

extension TimelineView: DOMPrimitive where Content: View {
  public var renderedBody: AnyView {
    AnyView(_TimelineView(parent: self))
  }
}

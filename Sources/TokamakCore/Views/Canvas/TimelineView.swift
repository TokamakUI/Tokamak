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
//  Created by Carson Katri on 9/17/21.
//

import Foundation

public struct TimelineView<Schedule, Content> where Schedule: TimelineSchedule {
  let schedule: Schedule
  let content: (Context) -> Content

  public struct Context {
    public enum Cadence: Hashable, Comparable {
      case live
      case seconds
      case minutes
    }

    let dateProvider: () -> Date
    public var date: Date { dateProvider() }
    public let cadence: Cadence
  }
}

extension TimelineView: View, _PrimitiveView where Content: View {
  public init(
    _ schedule: Schedule,
    @ViewBuilder content: @escaping (Context) -> Content
  ) {
    self.schedule = schedule
    self.content = content
  }
}

public struct _TimelineViewProxy<Schedule, Content> where Schedule: TimelineSchedule {
  let subject: TimelineView<Schedule, Content>

  public init(_ subject: TimelineView<Schedule, Content>) {
    self.subject = subject
  }

  public var schedule: Schedule { subject.schedule }
  public var content: (TimelineView<Schedule, Content>.Context) -> Content { subject.content }

  public func context(date: @escaping () -> Date) -> TimelineView<Schedule, Content>.Context {
    .init(dateProvider: date, cadence: .live)
  }
}

public protocol TimelineSchedule {
  typealias Mode = TimelineScheduleMode
  associatedtype Entries: Sequence where Entries.Element == Date
  func entries(from startDate: Date, mode: Self.Mode) -> Self.Entries
}

public enum TimelineScheduleMode: Hashable {
  case normal
  case lowFrequency
}

public extension TimelineSchedule where Self == PeriodicTimelineSchedule {
  @inlinable
  static func periodic(
    from startDate: Date,
    by interval: TimeInterval
  ) -> PeriodicTimelineSchedule {
    .init(from: startDate, by: interval)
  }
}

public extension TimelineSchedule where Self == EveryMinuteTimelineSchedule {
  @inlinable
  static var everyMinute: EveryMinuteTimelineSchedule { .init() }
}

public extension TimelineSchedule {
  static func explicit<S>(_ dates: S) -> ExplicitTimelineSchedule<S>
    where Self == ExplicitTimelineSchedule<S>, S.Element == Date
  {
    .init(dates)
  }
}

public struct PeriodicTimelineSchedule: TimelineSchedule {
  private let entries: Entries

  public struct Entries: Sequence, IteratorProtocol {
    var date: Date
    let interval: TimeInterval

    public mutating func next() -> Date? {
      defer { date.addTimeInterval(interval) }
      return date
    }

    public typealias Element = Date
    public typealias Iterator = Self
  }

  public init(from startDate: Date, by interval: TimeInterval) {
    entries = Entries(date: startDate, interval: interval)
  }

  public func entries(from startDate: Date, mode: TimelineScheduleMode) -> Entries {
    entries
  }
}

public struct EveryMinuteTimelineSchedule: TimelineSchedule {
  public struct Entries: Sequence, IteratorProtocol {
    var date: Date

    public mutating func next() -> Date? {
      defer { date.addTimeInterval(60) }
      return date
    }

    public typealias Element = Date
    public typealias Iterator = Self
  }

  public init() {}

  public func entries(
    from startDate: Date,
    mode: TimelineScheduleMode
  ) -> EveryMinuteTimelineSchedule.Entries {
    Entries(date: startDate)
  }
}

public struct ExplicitTimelineSchedule<Entries>: TimelineSchedule where Entries: Sequence,
  Entries.Element == Date
{
  private let dates: Entries

  public init(_ dates: Entries) {
    self.dates = dates
  }

  public func entries(from startDate: Date, mode: TimelineScheduleMode) -> Entries {
    dates
  }
}

public extension TimelineSchedule where Self == AnimationTimelineSchedule {
  @inlinable
  static var animation: AnimationTimelineSchedule { .init() }
  @inlinable
  static func animation(
    minimumInterval: Double? = nil,
    paused: Bool = false
  ) -> AnimationTimelineSchedule {
    .init(minimumInterval: minimumInterval, paused: paused)
  }
}

public struct AnimationTimelineSchedule: TimelineSchedule {
  private let minimumInterval: Double?
  public let _paused: Bool

  public struct Entries: Sequence, IteratorProtocol {
    var date: Date
    let minimumInterval: Double?
    let paused: Bool

    public mutating func next() -> Date? {
      guard !paused else { return nil }
      defer { date.addTimeInterval(minimumInterval ?? (1 / 60)) }
      return date
    }

    public typealias Element = Date
    public typealias Iterator = Self
  }

  public init(minimumInterval: Double? = nil, paused: Bool = false) {
    self.minimumInterval = minimumInterval
    _paused = paused
  }

  public func entries(from startDate: Date, mode: TimelineScheduleMode) -> Entries {
    Entries(date: startDate, minimumInterval: minimumInterval, paused: _paused)
  }
}

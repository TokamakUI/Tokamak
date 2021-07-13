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
//  Created by Emil Pedersen on 2021-03-26.
//

import struct Foundation.Date

/// A control for selecting an absolute date.
///
/// Available when `Label` conform to `View`.
public struct DatePicker<Label>: _PrimitiveView where Label: View {
  let label: Label
  let valueBinding: Binding<Date>
  let displayedComponents: DatePickerComponents
  let min: Date?
  let max: Date?

  public typealias Components = DatePickerComponents
}

public extension DatePicker {
  init(
    selection: Binding<Date>,
    in range: ClosedRange<Date>,
    displayedComponents: DatePickerComponents = [.hourAndMinute, .date],
    @ViewBuilder label: () -> Label
  ) {
    self.init(
      label: label(),
      valueBinding: selection,
      displayedComponents: displayedComponents,
      min: range.lowerBound,
      max: range.upperBound
    )
  }

  init(
    selection: Binding<Date>,
    displayedComponents: DatePickerComponents = [.hourAndMinute, .date],
    @ViewBuilder label: () -> Label
  ) {
    self.init(
      label: label(),
      valueBinding: selection,
      displayedComponents: displayedComponents,
      min: nil,
      max: nil
    )
  }

  init(
    selection: Binding<Date>,
    in range: PartialRangeFrom<Date>,
    displayedComponents: DatePickerComponents = [.hourAndMinute, .date],
    @ViewBuilder label: () -> Label
  ) {
    self.init(
      label: label(),
      valueBinding: selection,
      displayedComponents: displayedComponents,
      min: range.lowerBound,
      max: nil
    )
  }

  init(
    selection: Binding<Date>,
    in range: PartialRangeThrough<Date>,
    displayedComponents: DatePickerComponents = [.hourAndMinute, .date],
    @ViewBuilder label: () -> Label
  ) {
    self.init(
      label: label(),
      valueBinding: selection,
      displayedComponents: displayedComponents,
      min: nil,
      max: range.upperBound
    )
  }
}

public extension DatePicker where Label == Text {
  init<S>(
    _ title: S,
    selection: Binding<Date>,
    in range: ClosedRange<Date>,
    displayedComponents: DatePickerComponents = [.hourAndMinute, .date]
  ) where S: StringProtocol {
    self.init(
      label: Text(title),
      valueBinding: selection,
      displayedComponents: displayedComponents,
      min: range.lowerBound,
      max: range.upperBound
    )
  }

  init<S>(
    _ title: S,
    selection: Binding<Date>,
    displayedComponents: DatePickerComponents = [.hourAndMinute, .date]
  ) where S: StringProtocol {
    self.init(
      label: Text(title),
      valueBinding: selection,
      displayedComponents: displayedComponents,
      min: nil,
      max: nil
    )
  }

  init<S>(
    _ title: S,
    selection: Binding<Date>,
    in range: PartialRangeFrom<Date>,
    displayedComponents: DatePickerComponents = [.hourAndMinute, .date]
  ) where S: StringProtocol {
    self.init(
      label: Text(title),
      valueBinding: selection,
      displayedComponents: displayedComponents,
      min: range.lowerBound,
      max: nil
    )
  }

  init<S>(
    _ title: S,
    selection: Binding<Date>,
    in range: PartialRangeThrough<Date>,
    displayedComponents: DatePickerComponents = [.hourAndMinute, .date]
  ) where S: StringProtocol {
    self.init(
      label: Text(title),
      valueBinding: selection,
      displayedComponents: displayedComponents,
      min: nil,
      max: range.upperBound
    )
  }
}

public struct DatePickerComponents: OptionSet {
  public static let hourAndMinute = DatePickerComponents(rawValue: 1 << 0)
  public static let date = DatePickerComponents(rawValue: 1 << 1)

  public let rawValue: UInt

  public init(rawValue: UInt) {
    self.rawValue = rawValue
  }
}

/// This is a helper type that works around absence of "package private" access control in Swift
public struct _DatePickerProxy<Label> where Label: View {
  public let subject: DatePicker<Label>

  public init(_ subject: DatePicker<Label>) { self.subject = subject }

  public var label: Label { subject.label }
  public var valueBinding: Binding<Date> { subject.valueBinding }
  public var displayedComponents: DatePickerComponents { subject.displayedComponents }
  public var min: Date? { subject.min }
  public var max: Date? { subject.max }
}

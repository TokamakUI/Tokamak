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
//  Created by Carson Katri on 7/9/21.
//

import Foundation

public struct ProgressView<Label, CurrentValueLabel>: View
  where Label: View, CurrentValueLabel: View
{
  let storage: Storage

  enum Storage {
    case custom(_CustomProgressView<Label, CurrentValueLabel>)
    case foundation(_FoundationProgressView)
  }

  public var body: some View {
    switch storage {
    case let .custom(custom): custom
    case let .foundation(foundation): foundation
    }
  }
}

public struct _CustomProgressView<Label, CurrentValueLabel>: View
  where Label: View, CurrentValueLabel: View
{
  var fractionCompleted: Double?
  var label: Label?
  var currentValueLabel: CurrentValueLabel?

  @Environment(\.progressViewStyle)
  var style

  init(
    fractionCompleted: Double?,
    label: Label?,
    currentValueLabel: CurrentValueLabel?
  ) {
    self.fractionCompleted = fractionCompleted
    self.label = label
    self.currentValueLabel = currentValueLabel
  }

  public var body: some View {
    style.makeBody(
      configuration: .init(
        fractionCompleted: fractionCompleted,
        label: label.map { .init(body: AnyView($0)) },
        currentValueLabel: currentValueLabel.map { .init(body: AnyView($0)) }
      )
    )
  }
}

#if os(WASI)
public struct _FoundationProgressView: View {
  public var body: Never {
    fatalError("`Foundation.Progress` is not available.")
  }
}
#else
public struct _FoundationProgressView: View {
  let progress: Progress

  @State
  private var state: ProgressState?

  struct ProgressState {
    var progress: Double
    var isIndeterminate: Bool
    var description: String
  }

  init(_ progress: Progress) {
    self.progress = progress
  }

  public var body: some View {
    ProgressView(
      value: progress.isIndeterminate ? nil : progress.fractionCompleted
    ) {
      Text("\(Int(progress.fractionCompleted * 100))% completed")
    } currentValueLabel: {
      Text("\(progress.completedUnitCount)/\(progress.totalUnitCount)")
    }
  }
}
#endif

/// Override in renderers to provide a default body for determinate progress views.
public struct _FractionalProgressView: _PrimitiveView {
  public let fractionCompleted: Double
  init(_ fractionCompleted: Double) {
    self.fractionCompleted = fractionCompleted
  }
}

/// Override in renderers to provide a default body for indeterminate progress views.
public struct _IndeterminateProgressView: _PrimitiveView {}

public extension ProgressView where CurrentValueLabel == EmptyView {
  init() where Label == EmptyView {
    self.init(storage: .custom(
      .init(fractionCompleted: nil, label: nil, currentValueLabel: nil)
    ))
  }

  init(@ViewBuilder label: () -> Label) {
    self.init(storage: .custom(
      .init(fractionCompleted: nil, label: label(), currentValueLabel: nil)
    ))
  }

  init<S>(_ title: S) where Label == Text, S: StringProtocol {
    self.init {
      Text(title)
    }
  }
}

public extension ProgressView {
  init<V>(
    value: V?,
    total: V = 1.0
  ) where Label == EmptyView, CurrentValueLabel == EmptyView, V: BinaryFloatingPoint {
    self.init(storage: .custom(
      .init(
        fractionCompleted: value.map { Double($0 / total) },
        label: nil,
        currentValueLabel: nil
      )
    ))
  }

  init<V>(
    value: V?,
    total: V = 1.0,
    @ViewBuilder label: () -> Label
  ) where CurrentValueLabel == EmptyView, V: BinaryFloatingPoint {
    self.init(storage: .custom(
      .init(
        fractionCompleted: value.map { Double($0 / total) },
        label: label(),
        currentValueLabel: nil
      )
    ))
  }

  init<V>(
    value: V?,
    total: V = 1.0,
    @ViewBuilder label: () -> Label,
    @ViewBuilder currentValueLabel: () -> CurrentValueLabel
  ) where V: BinaryFloatingPoint {
    self.init(storage: .custom(
      .init(
        fractionCompleted: value.map { Double($0 / total) },
        label: label(),
        currentValueLabel: currentValueLabel()
      )
    ))
  }

  init<S, V>(
    _ title: S,
    value: V?,
    total: V = 1.0
  ) where Label == Text, CurrentValueLabel == EmptyView, S: StringProtocol, V: BinaryFloatingPoint {
    self.init(
      value: value,
      total: total
    ) {
      Text(title)
    }
  }
}

#if !os(WASI)
public extension ProgressView {
  init(_ progress: Progress) where Label == EmptyView, CurrentValueLabel == EmptyView {
    self.init(storage: .foundation(.init(progress)))
  }
}
#endif

public extension ProgressView {
  init(_ configuration: ProgressViewStyleConfiguration)
    where Label == ProgressViewStyleConfiguration.Label,
    CurrentValueLabel == ProgressViewStyleConfiguration.CurrentValueLabel
  {
    self.init(value: configuration.fractionCompleted) {
      ProgressViewStyleConfiguration.Label(
        body: AnyView(configuration.label)
      )
    } currentValueLabel: {
      ProgressViewStyleConfiguration.CurrentValueLabel(
        body: AnyView(configuration.currentValueLabel)
      )
    }
  }
}

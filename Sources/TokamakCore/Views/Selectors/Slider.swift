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

public enum _SliderStep {
  case any
  case discrete(Double.Stride)
}

private func convert<T>(_ binding: Binding<T>) -> Binding<Double> where T: BinaryFloatingPoint {
  Binding(get: { Double(binding.wrappedValue) }, set: { binding.wrappedValue = T($0) })
}

private func convert<T>(_ range: ClosedRange<T>) -> ClosedRange<Double> where T: BinaryFloatingPoint {
  Double(range.lowerBound)...Double(range.upperBound)
}

/// A control for selecting a value from a bounded linear range of values.
///
/// Available when `Label` and `ValueLabel` conform to `View`.
public struct Slider<Label, ValueLabel>: View where Label: View, ValueLabel: View {
  let label: Label
  let minValueLabel: ValueLabel
  let maxValueLabel: ValueLabel
  let valueBinding: Binding<Double>
  let bounds: ClosedRange<Double>
  let step: _SliderStep
  // FIXME: IMPLEMENT “For example, on iOS, a Slider is considered to be actively
  // editing while the user is touching the knob and sliding it around the track.”
  let onEditingChanged: (Bool) -> ()

  public var body: Never {
    neverBody("Slider")
  }
}

extension Slider where Label == EmptyView, ValueLabel == EmptyView {
  public init<V>(
    value: Binding<V>,
    in bounds: ClosedRange<V> = 0...1,
    onEditingChanged: @escaping (Bool) -> () = { _ in }
  ) where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    label = EmptyView()
    minValueLabel = EmptyView()
    maxValueLabel = EmptyView()
    valueBinding = convert(value)
    self.bounds = convert(bounds)
    step = .any
    self.onEditingChanged = onEditingChanged
  }

  public init<V>(
    value: Binding<V>,
    in bounds: ClosedRange<V>,
    step: V.Stride = 1,
    onEditingChanged: @escaping (Bool) -> () = { _ in }
  ) where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    label = EmptyView()
    minValueLabel = EmptyView()
    maxValueLabel = EmptyView()
    valueBinding = convert(value)
    self.bounds = convert(bounds)
    self.step = .discrete(Double.Stride(step))
    self.onEditingChanged = onEditingChanged
  }
}

extension Slider where ValueLabel == EmptyView {
  public init<V>(
    value: Binding<V>,
    in bounds: ClosedRange<V> = 0...1,
    onEditingChanged: @escaping (Bool) -> () = { _ in },
    label: () -> Label
  ) where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    self.label = label()
    minValueLabel = EmptyView()
    maxValueLabel = EmptyView()
    valueBinding = convert(value)
    self.bounds = convert(bounds)
    step = .any
    self.onEditingChanged = onEditingChanged
  }

  public init<V>(
    value: Binding<V>,
    in bounds: ClosedRange<V>,
    step: V.Stride = 1,
    onEditingChanged: @escaping (Bool) -> () = { _ in },
    label: () -> Label
  ) where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    self.label = label()
    minValueLabel = EmptyView()
    maxValueLabel = EmptyView()
    valueBinding = convert(value)
    self.bounds = convert(bounds)
    self.step = .discrete(Double.Stride(step))
    self.onEditingChanged = onEditingChanged
  }
}

extension Slider {
  public init<V>(
    value: Binding<V>,
    in bounds: ClosedRange<V> = 0...1,
    onEditingChanged: @escaping (Bool) -> () = { _ in },
    minimumValueLabel: ValueLabel,
    maximumValueLabel: ValueLabel,
    label: () -> Label
  ) where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    self.label = label()
    minValueLabel = minimumValueLabel
    maxValueLabel = maximumValueLabel
    valueBinding = convert(value)
    self.bounds = convert(bounds)
    step = .any
    self.onEditingChanged = onEditingChanged
  }

  public init<V>(
    value: Binding<V>,
    in bounds: ClosedRange<V>,
    step: V.Stride = 1,
    onEditingChanged: @escaping (Bool) -> () = { _ in },
    minimumValueLabel: ValueLabel,
    maximumValueLabel: ValueLabel,
    label: () -> Label
  ) where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    self.label = label()
    minValueLabel = minimumValueLabel
    maxValueLabel = maximumValueLabel
    valueBinding = convert(value)
    self.bounds = convert(bounds)
    self.step = .discrete(Double.Stride(step))
    self.onEditingChanged = onEditingChanged
  }
}

extension Slider: ParentView {
  public var children: [AnyView] {
    ((label as? GroupView)?.children ?? [AnyView(label)])
      + ((minValueLabel as? GroupView)?.children ?? [AnyView(minValueLabel)])
      + ((maxValueLabel as? GroupView)?.children ?? [AnyView(maxValueLabel)])
  }
}

/// This is a helper class that works around absence of "package private" access control in Swift
public struct _SliderProxy<Label, ValueLabel> where Label: View, ValueLabel: View {
  public let subject: Slider<Label, ValueLabel>

  public init(_ subject: Slider<Label, ValueLabel>) { self.subject = subject }

  public var label: Label { subject.label }
  public var minValueLabel: ValueLabel { subject.minValueLabel }
  public var maxValueLabel: ValueLabel { subject.maxValueLabel }
  public var valueBinding: Binding<Double> { subject.valueBinding }
  public var bounds: ClosedRange<Double> { subject.bounds }
  public var step: _SliderStep { subject.step }
  public var onEditingChanged: (Bool) -> () { subject.onEditingChanged }
}

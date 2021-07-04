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
//  Created by Carson Katri on 06/29/2020.
//

/// A scrollable view along a given axis.
///
/// By default, your app will overflow without the ability to scroll. Embed it in a `ScrollView`
/// to enable scrolling.
///
///     ScrollView {
///       ForEach(0..<10) {
///         Text("\($0)")
///       }
///     }
///
/// By default, the view will only expand to fit its children.
/// To make it fill its parent along the cross-axis, insert a stack with a `Spacer`:
///
///     ScrollView {
///       HStack { Spacer() } // Use VStack for a horizontal ScrollView
///       ForEach(0..<10) {
///         Text("\($0)")
///       }
///     }
public struct ScrollView<Content>: _PrimitiveView where Content: View {
  public let content: Content
  public let axes: Axis.Set
  public let showsIndicators: Bool

  public init(
    _ axes: Axis.Set = .vertical,
    showsIndicators: Bool = true,
    @ViewBuilder content: () -> Content
  ) {
    self.axes = axes
    self.showsIndicators = showsIndicators
    self.content = content()
  }
}

extension ScrollView: ParentView {
  @_spi(TokamakCore)
  public var children: [AnyView] {
    (content as? GroupView)?.children ?? [AnyView(content)]
  }
}

public struct PinnedScrollableViews: OptionSet {
  public let rawValue: UInt32
  public init(rawValue: UInt32) {
    self.rawValue = rawValue
  }

  public static let sectionHeaders: Self = .init(rawValue: 1 << 0)
  public static let sectionFooters: Self = .init(rawValue: 1 << 1)
}

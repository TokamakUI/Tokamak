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
//  Created by Max Desiatov on 08/04/2020.
//

/// An alignment position along the vertical axis.
public enum VerticalAlignment: Equatable {
  case top
  case center
  case bottom
}

/// A view that arranges its children in a horizontal line.
///
///     HStack {
///       Text("Hello")
///       Text("World")
///     }
public struct HStack<Content>: View where Content: View {
  public let alignment: VerticalAlignment
  public let spacing: CGFloat?
  public let content: Content
  fileprivate let helper = StackHelper(axis: .horizontal)

  public init(
    alignment: VerticalAlignment = .center,
    spacing: CGFloat? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.alignment = alignment
    self.spacing = spacing
    self.content = content()
  }

  public var body: Never {
    neverBody("HStack")
  }
}

extension HStack: ParentView {
  public var children: [AnyView] {
    (content as? GroupView)?.children ?? [AnyView(content)]
  }
}

extension HStack: BuiltinView {

  public func layout<T>(size: CGSize, hostView: MountedHostView<T>) {
    helper.layout(size: size, hostView: hostView)
  }

  public func size<T>(for proposedSize: ProposedSize, hostView: MountedHostView<T>) -> CGSize {
    helper.size(for: proposedSize, hostView: hostView)
  }
}

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

import Foundation

/// An alignment position along the horizontal axis.
public enum HorizontalAlignment: Equatable {
  case leading
  case center
  case trailing
}

/// A view that arranges its children in a vertical line.
///
///     VStack {
///       Text("Hello")
///       Text("World")
///     }
public struct VStack<Content>: _PrimitiveView where Content: View {
  public let alignment: HorizontalAlignment
  let spacing: CGFloat
  public let content: Content

  public init(
    alignment: HorizontalAlignment = .center,
    spacing: CGFloat? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.alignment = alignment
    self.spacing = spacing ?? defaultStackSpacing
    self.content = content()
  }
}

extension VStack: ParentView {
  @_spi(TokamakCore)
  public var children: [AnyView] {
    (content as? GroupView)?.children ?? [AnyView(content)]
  }
}

public struct _VStackProxy<Content> where Content: View {
  public let subject: VStack<Content>

  public init(_ subject: VStack<Content>) { self.subject = subject }

  public var spacing: CGFloat { subject.spacing }
}

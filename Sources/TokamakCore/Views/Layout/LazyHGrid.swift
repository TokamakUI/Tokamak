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
//  Created by Carson Katri on 7/13/20.
//

import Foundation

public struct LazyHGrid<Content>: _PrimitiveView where Content: View {
  let rows: [GridItem]
  let alignment: VerticalAlignment
  let spacing: CGFloat
  let pinnedViews: PinnedScrollableViews
  let content: Content

  public init(
    rows: [GridItem],
    alignment: VerticalAlignment = .center,
    spacing: CGFloat? = nil,
    pinnedViews: PinnedScrollableViews = .init(),
    @ViewBuilder content: () -> Content
  ) {
    self.rows = rows
    self.alignment = alignment
    self.spacing = spacing ?? 8
    self.pinnedViews = pinnedViews
    self.content = content()
  }
}

public struct _LazyHGridProxy<Content> where Content: View {
  public let subject: LazyHGrid<Content>

  public init(_ subject: LazyHGrid<Content>) { self.subject = subject }

  public var rows: [GridItem] { subject.rows }
  public var content: Content { subject.content }
  public var spacing: CGFloat { subject.spacing }
}

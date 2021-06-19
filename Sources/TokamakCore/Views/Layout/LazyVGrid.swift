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

public struct LazyVGrid<Content>: _PrimitiveView where Content: View {
  let columns: [GridItem]
  let alignment: HorizontalAlignment
  let spacing: CGFloat
  let pinnedViews: PinnedScrollableViews
  let content: Content

  public init(
    columns: [GridItem],
    alignment: HorizontalAlignment = .center,
    spacing: CGFloat? = nil,
    pinnedViews: PinnedScrollableViews = .init(),
    @ViewBuilder content: () -> Content
  ) {
    self.columns = columns
    self.alignment = alignment
    self.spacing = spacing ?? 8
    self.pinnedViews = pinnedViews
    self.content = content()
  }
}

public struct _LazyVGridProxy<Content> where Content: View {
  public let subject: LazyVGrid<Content>

  public init(_ subject: LazyVGrid<Content>) { self.subject = subject }

  public var columns: [GridItem] { subject.columns }
  public var content: Content { subject.content }
  public var spacing: CGFloat { subject.spacing }
}

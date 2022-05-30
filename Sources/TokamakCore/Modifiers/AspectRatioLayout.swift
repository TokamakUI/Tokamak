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

@frozen
public enum ContentMode: Hashable, CaseIterable {
  case fit
  case fill
}

public struct _AspectRatioLayout: ViewModifier {
  public let aspectRatio: CGFloat?
  public let contentMode: ContentMode

  @inlinable
  public init(aspectRatio: CGFloat?, contentMode: ContentMode) {
    self.aspectRatio = aspectRatio
    self.contentMode = contentMode
  }

  public func body(content: Content) -> some View {
    content
  }
}

public extension View {
  @inlinable
  func aspectRatio(
    _ aspectRatio: CGFloat? = nil,
    contentMode: ContentMode
  ) -> some View {
    modifier(
      _AspectRatioLayout(
        aspectRatio: aspectRatio,
        contentMode: contentMode
      )
    )
  }

  @inlinable
  func aspectRatio(
    _ aspectRatio: CGSize,
    contentMode: ContentMode
  ) -> some View {
    self.aspectRatio(
      aspectRatio.width / aspectRatio.height,
      contentMode: contentMode
    )
  }

  @inlinable
  func scaledToFit() -> some View {
    aspectRatio(contentMode: .fit)
  }

  @inlinable
  func scaledToFill() -> some View {
    aspectRatio(contentMode: .fill)
  }
}

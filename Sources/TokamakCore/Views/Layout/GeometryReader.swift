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

public struct GeometryProxy {
  @Environment(\._coordinateSpace)
  var coordinates
  let globalRect: CGRect

  public var size: CGSize {
    globalRect.size
  }

  public init(globalRect: CGRect) {
    self.globalRect = globalRect
  }

  public func frame(in coordinateSpace: CoordinateSpace) -> CGRect {
    switch coordinateSpace {
    case .global:
      return globalRect
    case .local:
      return CGRect(origin: .zero, size: size)
    case let .named(name):
      if let origin = coordinates.activeCoordinateSpace[CoordinateSpace.named(name)] {
        return CoordinateSpace.convertGlobalSpaceCoordinates(
          rect: globalRect,
          toNamedOrigin: origin
        )
      }
      // Return local if no space with given name
      return CGRect(origin: .zero, size: size)
    }
  }
}

public func makeProxy(from rect: CGRect) -> GeometryProxy {
  .init(globalRect: rect)
}

// public struct Anchor<Value> {
//   let box: AnchorValueBoxBase<Value>
//   public struct Source {
//     private var box: AnchorBoxBase<Value>
//   }
// }

// extension GeometryProxy {
//   public let safeAreaInsets: EdgeInsets
//   public subscript<T>(anchor: Anchor<T>) -> T {}
// }

public struct GeometryReader<Content>: _PrimitiveView where Content: View {
  public let content: (GeometryProxy) -> Content
  public init(@ViewBuilder content: @escaping (GeometryProxy) -> Content) {
    self.content = content
  }
}

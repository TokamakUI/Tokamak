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
//  Created by Szymon on 20/8/2023.
//

import Foundation

struct _CoordinateSpaceModifier<T: Hashable>: ViewModifier {
  @Environment(\._coordinateSpace)
  var coordinateSpace
  let name: T

  public func body(content: Content) -> some View {
    content
      .background {
        GeometryReader { proxy in
          EmptyView()
            .onChange(of: proxy.size, initial: true) {
              coordinateSpace.activeCoordinateSpace[.named(name)] = proxy
                .frame(in: .global).origin
            }
            .onDisappear {
              coordinateSpace.activeCoordinateSpace.removeValue(forKey: .named(name))
            }
        }
      }
  }
}

public extension View {
  /// Assigns a name to the view’s coordinate space, so other code can operate on dimensions like
  /// points and sizes relative to the named space.
  /// - Parameter name: A name used to identify this coordinate space.
  func coordinateSpace<T>(name: T) -> some View where T: Hashable {
    modifier(_CoordinateSpaceModifier(name: name))
  }
}

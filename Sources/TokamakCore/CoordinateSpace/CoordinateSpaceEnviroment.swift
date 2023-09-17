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
//  Created by Szymon on 19/8/2023.
//

import Foundation

private struct CoordinateSpaceEnvironmentKey: EnvironmentKey {
  static let defaultValue: CoordinateSpaceContext = .init()
}

extension EnvironmentValues {
  var _coordinateSpace: CoordinateSpaceContext {
    get { self[CoordinateSpaceEnvironmentKey.self] }
    set { self[CoordinateSpaceEnvironmentKey.self] = newValue }
  }
}

class CoordinateSpaceContext {
  /// Stores currently active CoordinateSpace against it's origin point in global coordinates
  var activeCoordinateSpace: [CoordinateSpace: CGPoint] = [:]
}

extension CoordinateSpace {
  static func convertGlobalSpaceCoordinates(
    rect: CGRect,
    toNamedOrigin namedOrigin: CGPoint
  ) -> CGRect {
    let translatedOrigin = convert(rect.origin, toNamedOrigin: namedOrigin)
    return CGRect(origin: translatedOrigin, size: rect.size)
  }

  static func convert(_ point: CGPoint, toNamedOrigin namedOrigin: CGPoint) -> CGPoint {
    CGPoint(x: point.x - namedOrigin.x, y: point.y - namedOrigin.y)
  }
}

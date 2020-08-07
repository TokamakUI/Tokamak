// Copyright 2018-2020 Tokamak contributors
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
//  Created by Carson Katri on 8/5/20.
//

import Runtime

extension ObjectIdentifier: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(hashValue)
  }
}

public final class ViewTree<R: Renderer> {
  public enum Context {
    case firstRender
    case update
  }

  public struct Node: Encodable, Hashable {
    let type: String
    let isPrimitive: Bool
    let isHost: Bool
    let dynamicProperties: [String]
    let target: String?
    var id: ObjectIdentifier
    var parent: ObjectIdentifier?

    public static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.id == rhs.id
    }

    init(type: Any.Type,
         isPrimitive: Bool,
         isHost: Bool,
         dynamicProperties: [String] = [],
         target: R.TargetType? = nil,
         object: MountedElement<R>,
         parent: MountedElement<R>? = nil) {
      self.type = "\(type)"
      id = ObjectIdentifier(object)
      self.isPrimitive = isPrimitive
      self.isHost = isHost
      self.dynamicProperties = dynamicProperties
      self.target = target?.debugIdentifier
      if let parent = parent {
        self.parent = ObjectIdentifier(parent)
      } else {
        self.parent = nil
      }
    }
  }
}

// Copyright 2022 Tokamak contributors
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
//  Created by Carson Katri on 5/30/22.
//

extension FiberReconciler.Fiber: CustomDebugStringConvertible {
  public var debugDescription: String {
    let memoryAddress = String(format: "%010p", unsafeBitCast(self, to: Int.self))
    if case let .view(view, _) = content,
       let text = view as? Text
    {
      return "Text(\"\(text.storage.rawText)\") (\(memoryAddress))"
    }
    return "\(typeInfo?.name ?? "Unknown") (\(memoryAddress))"
  }

  private func flush(level: Int = 0) -> String {
    let spaces = String(repeating: " ", count: level)
    let geometry = geometry ?? .init(
      origin: .init(origin: .zero),
      dimensions: .init(size: .zero, alignmentGuides: [:]),
      proposal: .unspecified
    )
    return """
    \(spaces)\(String(describing: typeInfo?.type ?? Any.self)
      .split(separator: "<")[0])\(element != nil ? "(\(element!))" : "") {\(element != nil ?
      "\n\(spaces)geometry: \(geometry)" :
      "")
    \(child?.flush(level: level + 2) ?? "")
    \(spaces)}
    \(sibling?.flush(level: level) ?? "")
    """
  }
}

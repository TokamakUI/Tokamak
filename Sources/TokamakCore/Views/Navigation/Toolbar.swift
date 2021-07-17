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
//  Created by Carson Katri on 7/7/20.
//

struct ToolbarKey: PreferenceKey {
  static let defaultValue = ToolbarValue([])
  static func reduce(value: inout ToolbarValue, nextValue: () -> ToolbarValue) {
    value = nextValue()
  }

  final class ToolbarValue: Equatable {
    let items: [AnyToolbarItem]
    init(_ items: [AnyToolbarItem]) {
      self.items = items
    }

    static func == (lhs: ToolbarValue, rhs: ToolbarValue) -> Bool {
      lhs === rhs
    }
  }
}

public extension View {
  @_disfavoredOverload
  func toolbar<Content>(
    @ViewBuilder content: @escaping () -> Content
  ) -> some View where Content: View {
    toolbar {
      ToolbarItem(placement: .automatic, content: content)
    }
  }

  func toolbar<Items>(@ToolbarContentBuilder<()> items: () -> ToolbarItemGroup<(), Items>)
    -> some View
  {
    preference(key: ToolbarKey.self, value: ToolbarKey.ToolbarValue(items()._items.compactMap {
      $0.view as? AnyToolbarItem
    }))
  }

  func toolbar<Items>(
    id: String,
    @ToolbarContentBuilder<String> items: () -> ToolbarItemGroup<String, Items>
  ) -> some View {
    preference(key: ToolbarKey.self, value: ToolbarKey.ToolbarValue(items()._items.compactMap {
      $0.view as? AnyToolbarItem
    }))
  }
}

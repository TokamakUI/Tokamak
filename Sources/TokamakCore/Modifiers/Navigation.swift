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

public extension View {
  @available(*, deprecated, renamed: "navigationTitle(_:)")
  func navigationBarTitle(_ title: Text) -> some View {
    navigationTitle(title)
  }

  @available(*, deprecated, renamed: "navigationTitle(_:)")
  func navigationBarTitle<S: StringProtocol>(_ title: S) -> some View {
    navigationTitle(title)
  }

  @available(
    *,
    deprecated,
    message: "Use navigationTitle(_:) with navigationBarTitleDisplayMode(_:)"
  )
  func navigationBarTitle(
    _ title: Text,
    displayMode: NavigationBarItem.TitleDisplayMode
  ) -> some View {
    navigationTitle(title)
      .navigationBarTitleDisplayMode(displayMode)
  }

  @available(
    *,
    deprecated,
    message: "Use navigationTitle(_:) with navigationBarTitleDisplayMode(_:)"
  )
  func navigationBarTitle<S: StringProtocol>(
    _ title: S,
    displayMode: NavigationBarItem.TitleDisplayMode
  ) -> some View {
    navigationTitle(title)
      .navigationBarTitleDisplayMode(displayMode)
  }

  func navigationTitle(_ title: Text) -> some View {
    navigationTitle { title }
  }

  func navigationTitle<S: StringProtocol>(_ titleKey: S) -> some View {
    navigationTitle(Text(titleKey))
  }

  func navigationTitle<V>(@ViewBuilder _ title: () -> V) -> some View
    where V: View
  {
    preference(key: NavigationTitleKey.self, value: AnyView(title()))
  }

  func navigationBarTitleDisplayMode(
    _ displayMode: NavigationBarItem
      .TitleDisplayMode
  ) -> some View {
    preference(key: NavigationBarItemKey.self, value: .init(displayMode: displayMode))
  }
}

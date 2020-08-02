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

public struct _ZIndexModifier: ViewModifier {
  public let index: Double

  public func body(content: Content) -> some View {
    content
  }
}

public extension View {
  /// Controls the display order of overlapping views.
  /// - Parameters:
  ///     - value: A relative front-to-back ordering for this view; the default is 0.
  func zIndex(_ value: Double = 0) -> some View {
    modifier(_ZIndexModifier(index: value))
  }
}

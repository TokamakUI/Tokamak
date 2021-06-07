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

@_spi(TokamakCore) import TokamakCore

extension Divider: AnyHTML {
  public func innerHTML(shouldSortAttributes: Bool) -> String? { nil }
  public var tag: String { "hr" }
  public var attributes: [HTMLAttribute: String] {
    [
      "style": """
      width: 100%; height: 0; margin: 0;
      border-top: none;
      border-right: none;
      border-bottom: 1px solid \(Color._withScheme {
        switch $0 {
        case .light: return .init(.sRGB, white: 0, opacity: 0.2)
        case .dark: return .init(.sRGB, white: 1, opacity: 0.2)
        }
      }.cssValue(environment));
      border-left: none;
      """,
    ]
  }
}

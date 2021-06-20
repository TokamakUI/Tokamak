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
//  Created by Carson Katri on 8/4/20.
//

@_spi(TokamakCore) import TokamakCore

// MARK: List Colors

extension Color {
  static var listSectionHeader: Self {
    Color._withScheme {
      switch $0 {
      case .light: return Color(0xDDDDDD)
      case .dark: return Color(0x323234)
      }
    }
  }

  static var groupedListBackground: Self {
    Color._withScheme {
      switch $0 {
      case .light: return Color(0xEEEEEE)
      case .dark: return .clear
      }
    }
  }

  static var listGroupBackground: Self {
    Color._withScheme {
      switch $0 {
      case .light: return .white
      case .dark: return Color(0x444444)
      }
    }
  }

  static var sidebarBackground: Self {
    Color._withScheme {
      switch $0 {
      case .light: return Color(0xF2F2F7)
      case .dark: return Color(0x2D2B30)
      }
    }
  }
}

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
//  Created by Carson Katri on 7/12/21.
//

public enum ControlSize: CaseIterable, Hashable {
  case mini
  case small
  case regular
  case large
}

extension EnvironmentValues {
  private enum ControlSizeKey: EnvironmentKey {
    static var defaultValue: ControlSize = .regular
  }

  public var controlSize: ControlSize {
    get {
      self[ControlSizeKey.self]
    }
    set {
      self[ControlSizeKey.self] = newValue
    }
  }
}

public extension View {
  @inlinable
  func controlSize(
    _ controlSize: ControlSize
  ) -> some View {
    environment(\.controlSize, controlSize)
  }
}

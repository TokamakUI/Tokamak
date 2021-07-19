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

public enum Prominence: Hashable {
  case standard
  case increased
}

extension EnvironmentValues {
  private enum ControlProminenceKey: EnvironmentKey {
    static var defaultValue: Prominence = .standard
  }

  public var controlProminence: Prominence {
    get {
      self[ControlProminenceKey.self]
    }
    set {
      self[ControlProminenceKey.self] = newValue
    }
  }

  private enum HeaderProminenceKey: EnvironmentKey {
    static var defaultValue: Prominence = .standard
  }

  public var headerProminence: Prominence {
    get {
      self[HeaderProminenceKey.self]
    }
    set {
      self[HeaderProminenceKey.self] = newValue
    }
  }
}

public extension View {
  func controlProminence(_ prominence: Prominence) -> some View {
    environment(\.controlProminence, prominence)
  }

  func headerProminence(_ prominence: Prominence) -> some View {
    environment(\.headerProminence, prominence)
  }
}

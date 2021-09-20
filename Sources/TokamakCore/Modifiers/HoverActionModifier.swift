// Copyright 2021 Tokamak contributors
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
/// Underscore is present in the name for SwiftUI compatibility.
public struct _HoverActionModifier: ViewModifier {
  public var hover: ((Bool) -> ())?

  public typealias Body = Never
}

extension ModifiedContent
  where Content: View, Modifier == _HoverActionModifier
{
  var hover: ((Bool) -> ())? { modifier.hover }
}

public extension View {
  func onHover(perform action: ((Bool) -> ())?) -> some View {
    modifier(_HoverActionModifier(hover: action))
  }
}

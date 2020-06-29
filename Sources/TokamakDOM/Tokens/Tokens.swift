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

import TokamakCore

public typealias Font = TokamakCore.Font
public typealias Color = TokamakCore.Color

extension Color: CustomStringConvertible {
  public var description: String {
    "rgb(\(red * 255), \(green * 255), \(blue * 255), \(alpha * 255))"
  }
}

public typealias CGRect = TokamakCore.CGRect
public typealias CGPoint = TokamakCore.CGPoint
public typealias CGSize = TokamakCore.CGSize
public typealias CGAffineTransform = TokamakCore.CGAffineTransform

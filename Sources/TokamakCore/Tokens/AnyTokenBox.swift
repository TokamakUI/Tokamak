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
//  Created by Carson Katri on 10/24/2020.
//

/// Allows "late-binding tokens" to be resolved in an environment by a `Renderer` (or `TokamakCore`)
public protocol AnyTokenBox: AnyObject {
  associatedtype ResolvedValue
  func resolve(in environment: EnvironmentValues) -> ResolvedValue
}

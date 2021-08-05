// Copyright 2020-2021 Tokamak contributors
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
//  Created by Ezra Berch on 8/5/21.
//

#if !os(WASI)
public enum Sanitizers {
  public enum HTML {
    public static let insecure: (String) -> String = { $0 }
    public static let encode: (String) -> String = { $0 }
  }
}

public extension Text {
  init(verbatim content: String, sanitizer: (String) -> String) { self = Self(content) }

  init<S>(_ content: S, sanitizer: (String) -> String)
    where S: StringProtocol { self = Self(String(content)) }
}
#endif

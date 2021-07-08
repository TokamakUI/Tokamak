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
//  Created by Carson Katri on 7/8/21.
//

import Foundation

protocol Sanitizer {
  associatedtype Input
  associatedtype Output
  static func sanitize(_ input: Input) -> Output
}

enum Sanitizers {
  enum CSS {
    static func sanitize(string inputs: [String]) -> String {
      inputs.map(StringValue.sanitize).joined(separator: ", ")
    }

    static func sanitize(string inputs: String...) -> String {
      sanitize(string: inputs)
    }

    enum StringValue: Sanitizer {
      static func sanitize(_ input: String) -> String {
        """
        '\(input.filter {
          $0.isLetter || $0.isNumber
            || $0 == "-" || $0 == "_" || $0 == " "
            || $0.unicodeScalars.allSatisfy { $0 > "\u{00A0}" }
        })'
        """
      }
    }
  }
}

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
  static func validate(_ input: Input) -> Bool
  static func sanitize(_ input: Input) -> Output
}

enum Sanitizers {
  enum CSS {
    /// Automatically sanitizes a value.
    static func sanitize(_ value: String) -> String {
      if value.starts(with: "'") || value.starts(with: "\"") {
        return sanitize(string: value)
      } else {
        return validate(identifier: value)
          ? sanitize(identifier: value)
          : sanitize(string: value)
      }
    }

    static func sanitize(identifier: String) -> String {
      Identifier.sanitize(identifier)
    }

    static func sanitize(string: String) -> String {
      StringValue.sanitize(string)
    }

    static func validate(identifier: String) -> Bool {
      Identifier.validate(identifier)
    }

    static func validate(string: String) -> Bool {
      StringValue.validate(string)
    }

    /// Sanitizes an identifier.
    enum Identifier: Sanitizer {
      static func isIdentifierChar(_ char: Character) -> Bool {
        char.isLetter || char.isNumber
          || char == "-" || char == "_"
          || char.unicodeScalars.allSatisfy { $0 > "\u{00A0}" }
      }

      static func validate(_ input: String) -> Bool {
        input.allSatisfy(isIdentifierChar)
      }

      static func sanitize(_ input: String) -> String {
        input.filter(isIdentifierChar)
      }
    }

    /// Sanitizes a quoted string.
    enum StringValue: Sanitizer {
      static func isStringContent(_ char: Character) -> Bool {
        char != "'" && char != "\""
      }

      static func validate(_ input: String) -> Bool {
        input.starts(with: "'") || input.starts(with: "\"")
          && !input.dropFirst().dropLast().allSatisfy(isStringContent)
          && input.last == input.first
      }

      static func sanitize(_ input: String) -> String {
        """
        '\(input.filter(isStringContent))'
        """
      }
    }
  }
}

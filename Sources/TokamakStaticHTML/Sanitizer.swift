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

public enum Sanitizers {
  enum CSS {
    /// Automatically sanitizes a value.
    static func sanitize(_ value: String) -> String {
      if value.starts(with: "'") || value.starts(with: "\"") {
        return sanitize(string: value)
      } else {
        return validate(identifier: value)
          ? value
          : sanitize(string: "'\(value)'")
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

    /// Parsers for CSS grammar.
    ///
    /// Specified on [w3.org](https://www.w3.org/TR/CSS21/grammar.html)
    private enum Parsers {
      /// `[0-9a-f]`
      static let h: RegularExpression = #"[0-9a-f]"#

      /// `[\240-\377]`
      static let nonAscii: RegularExpression = #"[\0240-\0377]"#

      /// `\\{h}{1,6}(\r\n|[ \t\r\n\f])?`
      static let unicode: RegularExpression = #"\\\#(h){1,6}(\r\n|[ \t\r\n\f])?"#

      /// `{unicode}|\\[^\r\n\f0-9a-f]`
      static let escape: RegularExpression = #"\#(unicode)|\\[^\r\n\f0-9a-f]"#

      /// `[_a-z]|{nonascii}|{escape}`
      static let nmStart: RegularExpression = #"[_a-z]|\#(nonAscii)|\#(escape)"#
      /// `[_a-z0-9-]|{nonascii}|{escape}`
      static let nmChar: RegularExpression = #"[_a-z0-9-]|\#(nonAscii)|\#(escape)"#

      /// `\"([^\n\r\f\\"]|\\{nl}|{escape})*\"`
      static let string1Content: RegularExpression = #"([^\n\r\f\\"]|\\\#(nl)|\#(escape))*"#
      static let string1: RegularExpression = #""\#(string1Content)""#
      /// `\'([^\n\r\f\\']|\\{nl}|{escape})*\'`
      static let string2Content: RegularExpression = #"([^\n\r\f\\']|\\\#(nl)|\#(escape))*"#
      static let string2: RegularExpression = #"'\#(string2Content)'"#

      /// `-?{nmstart}{nmchar}*`
      static let ident: RegularExpression = #"-?\#(nmStart)\#(nmChar)*"#

      /// `\n|\r\n|\r|\f`
      static let nl: RegularExpression = #"\n|\r\n|\r|\f"#
    }

    /// Sanitizes an identifier.
    enum Identifier: Sanitizer {
      static func validate(_ input: String) -> Bool {
        Parsers.ident.matches(input)
      }

      static func sanitize(_ input: String) -> String {
        Parsers.ident.filter(input)
      }
    }

    /// Sanitizes a quoted string.
    enum StringValue: Sanitizer {
      static func validate(_ input: String) -> Bool {
        Parsers.string1.matches(input)
          || Parsers.string2.matches(input)
      }

      static func sanitize(_ input: String) -> String {
        """
        '\(
          Parsers.string1.matches(input)
            ? Parsers.string1Content.filter(input)
            : Parsers.string2Content.filter(input)
            .replacingOccurrences(of: "\"", with: "&quot;"))'
        """
      }
    }
  }

  public enum HTML {
    public static let encode = Encode.sanitize
    public static let insecure = Insecure.sanitize

    typealias Default = Encode

    enum Encode: Sanitizer {
      static func validate(_ input: String) -> Bool {
        input == sanitize(input)
      }

      static func sanitize(_ input: String) -> String {
        let controlCharacters = [("&", "&amp;"),
                                 ("<", "&lt;"),
                                 (">", "&gt;"),
                                 ("\"", "&quot;"),
                                 ("'", "&#x27;")]

        return controlCharacters.reduce(input) { input, replacement in
          let (from, to) = replacement
          return input.replacingOccurrences(of: from, with: to)
        }
      }
    }

    enum Insecure: Sanitizer {
      static func validate(_ input: String) -> Bool { true }
      static func sanitize(_ input: String) -> String { input }
    }
  }
}

struct RegularExpression: ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
  let pattern: String
  private let nsRegularExpression: NSRegularExpression?

  init(_ pattern: String) {
    self.pattern = pattern
    nsRegularExpression = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
  }

  init(stringLiteral value: String) {
    self.init(value)
  }

  init(stringInterpolation: StringInterpolation) {
    self.init(stringInterpolation.pattern)
  }

  func matches(_ input: String) -> Bool {
    guard let range = input.range(
      of: pattern,
      options: [.regularExpression, .caseInsensitive, .anchored]
    ) else { return false }
    return range.lowerBound == input.startIndex && range.upperBound == input.endIndex
  }

  func filter(_ input: String) -> String {
    nsRegularExpression?
      .matches(
        in: input,
        options: [],
        range: NSRange(location: 0, length: input.utf16.count)
      )
      .compactMap {
        guard let range = Range($0.range, in: input) else { return nil }
        return String(input[range])
      }
      .joined() ?? ""
  }

  struct StringInterpolation: StringInterpolationProtocol {
    var pattern: String = ""

    init(literalCapacity: Int, interpolationCount: Int) {
      pattern.reserveCapacity(literalCapacity + interpolationCount)
    }

    mutating func appendLiteral(_ literal: String) {
      pattern.append(literal)
    }

    mutating func appendInterpolation(_ regex: RegularExpression) {
      pattern.append("(\(regex.pattern))")
    }
  }
}

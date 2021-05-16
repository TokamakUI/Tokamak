// MIT License
//
// Copyright (c) 2019 Sergej Jaskiewicz
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
//  Created by Sergej Jaskiewicz on 31.10.2019.
//

import CReflection

struct FieldInfo: Equatable, CustomDebugStringConvertible {
  let name: String
  let offset: Int
  let type: Any.Type

  init(_ name: String, _ offset: Int, _ type: Any.Type) {
    self.name = name
    self.offset = offset
    self.type = type
  }

  static func == (lhs: FieldInfo, rhs: FieldInfo) -> Bool {
    lhs.name == rhs.name &&
      lhs.offset == rhs.offset &&
      lhs.type == rhs.type
  }

  var debugDescription: String {
    "(name: \(name.debugDescription), offset: \(offset), type: \(type).self)"
  }
}

typealias FieldEnumerator = (FieldInfo) -> Bool

func enumerateFields(
  of type: Any.Type,
  allowResilientSuperclasses: Bool,
  enumerator: FieldEnumerator
) {
  withoutActuallyEscaping(enumerator) { enumerator in
    var context = enumerator
    enumerateFields(
      typeMetadata: unsafeBitCast(type, to: UnsafeRawPointer.self),
      allowResilientSuperclasses: allowResilientSuperclasses,
      enumeratorContext: &context,
      enumerator: { rawContext, fieldName, fieldOffset, rawMetadataPtr in
        let fieldInfo = FieldInfo(
          String(cString: fieldName),
          fieldOffset,
          unsafeBitCast(rawMetadataPtr, to: Any.Type.self)
        )
        return rawContext
          .unsafelyUnwrapped
          .assumingMemoryBound(to: FieldEnumerator.self)
          .pointee(fieldInfo)
      }
    )
  }
}

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

typealias FieldEnumerator =
  (_ fieldName: UnsafePointer<CChar>, _ fieldOffset: Int, _ fieldType: Any.Type) -> Bool

func enumerateFields(
  of type: Any.Type,
  allowResilientSuperclasses: Bool,
  enumerator: FieldEnumerator
) {
  // A neat trick to pass a Swift closure where a C function pointer is expected.
  // (Unlike closures, function pointers cannot capture context)
  withoutActuallyEscaping(enumerator) { enumerator in
    var context = enumerator
    enumerateFields(
      typeMetadata: UnsafeRawPointer(bitPattern: unsafeBitCast(type, to: Int.self))!,
      allowResilientSuperclasses: allowResilientSuperclasses,
      enumeratorContext: &context,
      enumerator: { rawContext, fieldName, fieldOffset, rawMetadataPtr in
        rawContext
          .unsafelyUnwrapped
          .bindMemory(to: FieldEnumerator.self, capacity: 1)
          .pointee(
            fieldName,
            fieldOffset,
            unsafeBitCast(rawMetadataPtr, to: Any.Type.self)
          )
      }
    )
  }
}

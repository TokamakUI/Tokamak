// MIT License
//
// Copyright (c) 2017-2021 Wesley Wickwire and Tokamak contributors
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

import CReflection

public struct TypeInfo {
  public let type: Any.Type
  public let properties: [PropertyInfo]
  public let size: Int

  public func property(named: String) -> PropertyInfo? {
    properties.first(where: { $0.name == named })
  }
}

public func typeInfo(of type: Any.Type) -> TypeInfo {
  let metadataPointer = UnsafeRawPointer(bitPattern: unsafeBitCast(type, to: Int.self))!

  assert(
    _checkMetadataState(
      .init(desiredState: .layoutComplete, isBlocking: false),
      metadataPointer
    ).state.rawValue < MetadataState.layoutComplete.rawValue,
    """
    Struct metadata for \(type) is in incomplete state, \
    proceeding would result in an undefined behavior.
    """
  )

  var properties = [PropertyInfo]()

  enumerateFields(
    of: type,
    allowResilientSuperclasses: false
  ) {
    properties.append(
      .init(
        name: String(cString: $0),
        type: $2,
        offset: $1,
        ownerType: type
      )
    )
    return true
  }

  return TypeInfo(type: type, properties: properties, size: tokamak_get_size(metadataPointer))
}

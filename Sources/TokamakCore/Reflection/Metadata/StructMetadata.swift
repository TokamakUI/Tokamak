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

struct StructMetadata {
  let pointer: UnsafePointer<StructMetadataLayout>

  func toTypeInfo() -> TypeInfo {
    TypeInfo(metadata: self)
  }

  func mangledName() -> String {
    let base = pointer.pointee.typeDescriptor
    let offset = MemoryLayout<StructTypeDescriptor>
      .offset(of: \StructTypeDescriptor.mangledName)!
    return String(cString: base.pointee.mangledName.apply(to: base.raw.advanced(by: offset)))
  }

  func properties() -> [PropertyInfo] {
    var result = [PropertyInfo]()

    enumerateFields(
      of: type,
      allowResilientSuperclasses: false
    ) {
      result.append(
        .init(
          name: String(cString: $0),
          type: $2,
          offset: $1,
          ownerType: type
        )
      )
      return true
    }

    return result
  }

  var type: Any.Type {
    unsafeBitCast(pointer, to: Any.Type.self)
  }

  var kind: Kind {
    Kind(flag: pointer.pointee._kind)
  }

  var size: Int {
    valueWitnessTable.pointee.size
  }

  /// The ValueWitnessTable for the type.
  /// A pointer to the table is located one pointer sized word behind the metadata pointer.
  var valueWitnessTable: UnsafePointer<ValueWitnessTable> {
    pointer
      .raw
      .advanced(by: -MemoryLayout<UnsafeRawPointer>.size)
      .assumingMemoryBound(to: UnsafePointer<ValueWitnessTable>.self)
      .pointee
  }
}

extension StructMetadata {
  init(type: Any.Type) {
    self = Self(pointer: unsafeBitCast(type, to: UnsafePointer<StructMetadataLayout>.self))
    assert(
      _checkMetadataState(
        .init(desiredState: .layoutComplete, isBlocking: false),
        self
      ).state.rawValue < MetadataState.layoutComplete.rawValue,
      """
      Struct metadata for \(type) is in incomplete state, \
      proceeding would result in an undefined behavior.
      """
    )
  }
}

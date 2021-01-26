// MIT License
//
// Copyright (c) 2017 Wesley Wickwire
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
  var pointer: UnsafeMutablePointer<StructMetadataLayout>

  mutating func toTypeInfo() -> TypeInfo {
    var info = TypeInfo(metadata: self)
    info.properties = properties()
    info.mangledName = mangledName()
    info.genericTypes = Array(genericArguments())
    return info
  }

  var genericArgumentOffset: Int {
    // default to 2. This would put it right after the type descriptor which is valid
    // for all types except for classes
    2
  }

  var isGeneric: Bool {
    (pointer.pointee.typeDescriptor.pointee.flags & 0x80) != 0
  }

  mutating func mangledName() -> String {
    String(cString: pointer.pointee.typeDescriptor.pointee.mangledName.advanced())
  }

  mutating func numberOfFields() -> Int {
    Int(pointer.pointee.typeDescriptor.pointee.numberOfFields)
  }

  mutating func fieldOffsets() -> [Int] {
    pointer.pointee.typeDescriptor.pointee
      .offsetToTheFieldOffsetVector
      .vector(metadata: pointer.raw.assumingMemoryBound(to: Int.self), n: numberOfFields())
      .map(numericCast)
  }

  mutating func properties() -> [PropertyInfo] {
    let offsets = fieldOffsets()
    let fieldDescriptor = pointer.pointee.typeDescriptor.pointee
      .fieldDescriptor
      .advanced()

    let genericVector = genericArgumentVector()

    return (0..<numberOfFields()).map { i in
      let record = fieldDescriptor
        .pointee
        .fields
        .element(at: i)

      return PropertyInfo(
        name: record.pointee.fieldName(),
        type: record.pointee.type(
          genericContext: pointer.pointee.typeDescriptor,
          genericArguments: genericVector
        ),
        isVar: record.pointee.isVar,
        offset: offsets[i],
        ownerType: type
      )
    }
  }

  func genericArguments() -> UnsafeMutableBufferPointer<Any.Type> {
    guard isGeneric else { return .init(start: nil, count: 0) }

    let count = pointer.pointee
      .typeDescriptor
      .pointee
      .genericContextHeader
      .base
      .numberOfParams
    return genericArgumentVector().buffer(n: Int(count))
  }

  func genericArgumentVector() -> UnsafeMutablePointer<Any.Type> {
    pointer
      .advanced(by: genericArgumentOffset, wordSize: MemoryLayout<UnsafeRawPointer>.size)
      .assumingMemoryBound(to: Any.Type.self)
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

  var alignment: Int {
    (valueWitnessTable.pointee.flags & ValueWitnessFlags.alignmentMask) + 1
  }

  var stride: Int {
    valueWitnessTable.pointee.stride
  }

  /// The ValueWitnessTable for the type.
  /// A pointer to the table is located one pointer sized word behind the metadata pointer.
  var valueWitnessTable: UnsafeMutablePointer<ValueWitnessTable> {
    pointer
      .raw
      .advanced(by: -MemoryLayout<UnsafeRawPointer>.size)
      .assumingMemoryBound(to: UnsafeMutablePointer<ValueWitnessTable>.self)
      .pointee
  }
}

extension StructMetadata {
  init(type: Any.Type) {
    self = Self(pointer: unsafeBitCast(type, to: UnsafeMutablePointer<StructMetadataLayout>.self))
  }
}

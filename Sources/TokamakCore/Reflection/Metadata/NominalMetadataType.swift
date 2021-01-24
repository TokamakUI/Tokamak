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

protocol NominalMetadataType: MetadataType where Layout: NominalMetadataLayoutType {
  /// The offset of the generic type vector in pointer sized words from the
  /// start of the metadata record.
  var genericArgumentOffset: Int { get }
}

extension NominalMetadataType {
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
}

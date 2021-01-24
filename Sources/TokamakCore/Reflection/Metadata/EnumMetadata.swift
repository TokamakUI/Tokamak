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

struct EnumMetadata: NominalMetadataType {
  var pointer: UnsafeMutablePointer<EnumMetadataLayout>

  var numberOfPayloadCases: UInt32 {
    pointer.pointee.typeDescriptor.pointee.numPayloadCasesAndPayloadSizeOffset & 0x00FF_FFFF
  }

  var numberOfCases: UInt32 {
    pointer.pointee.typeDescriptor.pointee.numEmptyCases + numberOfPayloadCases
  }

  mutating func cases() -> [Case] {
    guard pointer.pointee.typeDescriptor.pointee.fieldDescriptor.offset != 0 else {
      return []
    }

    let fieldDescriptor = pointer.pointee
      .typeDescriptor.pointee
      .fieldDescriptor.advanced()

    let genericVector = genericArgumentVector()

    return (0..<numberOfCases).map { i in
      let record = fieldDescriptor
        .pointee
        .fields
        .element(at: Int(i))

      return Case(
        name: record.pointee.fieldName(),
        payloadType: record.pointee._mangledTypeName.offset == 0
          ? nil
          : record.pointee.type(
            genericContext: pointer.pointee.typeDescriptor,
            genericArguments: genericVector
          )
      )
    }
  }

  mutating func toTypeInfo() -> TypeInfo {
    var info = TypeInfo(metadata: self)
    info.mangledName = mangledName()
    info.cases = cases()
    info.genericTypes = Array(genericArguments())
    info.numberOfEnumCases = Int(numberOfCases)
    info.numberOfPayloadEnumCases = Int(numberOfPayloadCases)
    return info
  }
}

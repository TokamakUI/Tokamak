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

protocol MetadataInfo {
  var kind: Kind { get }
  var size: Int { get }
  var alignment: Int { get }
  var stride: Int { get }

  init(type: Any.Type)
}

protocol MetadataType: MetadataInfo, TypeInfoConvertible {
  associatedtype Layout: MetadataLayoutType

  var pointer: UnsafeMutablePointer<Layout> { get set }

  init(pointer: UnsafeMutablePointer<Layout>)
}

extension MetadataType {
  init(type: Any.Type) {
    self = Self(pointer: unsafeBitCast(type, to: UnsafeMutablePointer<Layout>.self))
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

  mutating func toTypeInfo() -> TypeInfo {
    TypeInfo(metadata: self)
  }
}
